
Under `layers`: a collection of `kustomize` templates for running Spring Boot applications. Under `compose`: a collection of docker-compose.yml files useful for running data services (e.g. redis, rabbit, mongo) locally.

## Kustomize Layers

Examples:

```
$ kustomize build layers/samples/petclinic | kubectl apply -f -
```

Another one with the source code for the Spring Boot application under `demo`:

```
$ cd demo
$ mvn install
$ docker build -t dsyer/demo .
$ kapp deploy -a demo -f $(kustomize build k8s/dev)
```

See [K8s Tutorial](k8s-tutorial.adoc) for more detail.

## Compose Service Templates

To run in a VM or a remote platform you can use `docker-machine` and an ssh tunnel to map the ports to localhost. E.g. for redis

```
$ machine=splash # arbitrary name
$ docker create $machine # add options for --driver
$ eval "$(docker-machine env $machine)"
$ (cd redis; docker-compose up)
$ docker-machine ssh $machine -- -L 6379:localhost:6379
# in another terminal:
$ redis-cli
128.0.0.1:6379>
```

> TIP: to break out of an ssh tunnel use `Enter ~ .` (key sequence).

> NOTE: the tunnel is `$remoteport:localhost:$localport` (the opposite order to `docker -p`).

To create the machine on EC2 use `--driver amazonec2` with 

```
AWS_DEFAULT_REGION=eu-west-1
AWS_SECRET_ACCESS_KEY=...
AWS_ACCESS_KEY_ID=...
AWS_VPC_ID=...
```
where the VPC id can be copied from [AWS Console](https://console.aws.amazon.com) (it has to be in the region specified and the 'a' availability zone by default).

> NOTE: you can automate the tunnel creation with a script, e.g. `docker-tunnel $machine 6379 3303`.

## Tips

Disk full? Clean up:

```
$ docker rm $(docker ps -a -f status=exited -q)
$ docker rmi $(docker images -f dangling=true -q)
$ docker volume rm $(docker volume ls -f dangling=true -q)
```

Run as current user:

```
$ docker run -ti -v ${HOME}:${HOME} -e HOME --user $(id -u):$(id -g) ubuntu /bin/bash
/$ cd
~$
```

## Docker in Docker

```
$ docker run -v /var/run/docker.sock:/var/run/docker.sock -ti openjdk:8-alpine /bin/sh
/# apk add --no-cache docker
/# docker ps
```

## GKE

### Service Accounts

There are 2 kinds of service accounts. It's confusing. One is for k8s and just for the cluster, another is a GCP global thing (so you can use other GCP services from GKE for instance).

It's easy to create a new service account in the k8s cluster, but it won't be very much use until it has some permissions. To grant permissions you need to be an admin yourself, so escalate your own credentials first

```
kubectl --username=admin --password=$PASSWORD create clusterrolebinding dsyer-cluster-admin-binding --clusterrole=cluster-admin --user=dsyer@pivotal.io
```

(You can copy the password from the GKE dashboard if you go to the cluster details and click on the "Show credentials" link on the k8s endpoint.)

Then apply some YAML that creates the service account and a role and binds them together (this example uses "builder" as the user name and the role name):

```
$ kubectl apply -f serviceaccount.yaml
$ cat serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: builder
---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: builder
rules:
  - apiGroups: [""]
    resources: ["services", "pods"]
    verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
  - apiGroups: ["extensions"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
  - apiGroups: ["projectriff.io"]
    resources: ["functions", "topics"]
    verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: builder
roleRef:
  kind: Role
  name: builder
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: builder
```

A pod runs containers with permissions from a service account. By default it is called "default", but you can change that in the deployment (or pod) spec:

```
$ kubectl get deployment builder -o yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    function: builder
  name: builder
spec:
  replicas: 1
  selector:
    matchLabels:
      function: builder
  template:
    metadata:
      labels:
        function: builder
      name: builder
    spec:
      containers:
      - image: dsyer/builder:0.0.1
        name: main
        volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-sock-volume
      # ...
      serviceAccountName: builder
      volumes:
      - hostPath:
          path: /var/run/docker.sock
          type: File
        name: docker-sock-volume
---

apiVersion : projectriff.io/v1
kind: Topic
metadata:	
  name: builds

```

### Single Node No Registry

If you create a cluster for a smallish system just for development, you can make it a single node (like a minikube), and then you don't need a Docker registry for deployments. Useful article on [this pattern](https://ahmet.im/blog/minikube-on-gke/). Remember to create the cluster with more resources (e.g. 4 cores) if you have more than a few pods running in the final state.

Create a tunnel:

```
$ gcloud compute ssh $(kubectl get nodes -o=custom-columns=:metadata.name) -- -N -o StreamLocalBindUnlink=yes -L $HOME/gke.sock:/var/run/docker.sock 
```

and then:

```
$ export DOCKER_HOST=unix:///$HOME/gke.sock
$ docker build -t dsyer/demo:0.0.1 .
$ kubectl run --image=dsyer/demo demo --port=8080
```

Even nicer, you can run docker in a container (either locally or in GKE), and point to that socket. Locally, when you don't already have `DOCKER_HOST` set as above:

```
$ docker run -v /var/run/docker.sock:$HOME/gke.sock -ti dsyer/builder:0.0.1 /bin/sh
```

If you already have `DOCKER_HOST` then this works:

```
$ docker run -v /var/run/docker.sock:/var/run/docker.sock -ti dsyer/builder:0.0.1 /bin/sh
```

The images will not be usable by k8s (even if you can run them with docker) unless they have a "concrte" label, like "0.0.1" (not "latest"). Easy mistake to make, results in a load of `ImagePullBackoff`.

### Private Registry

Articles on private Docker regsitry in GKE:

* [Offical Kubernetes docs](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/). Note the need for every pod spec to refer to the `imagePullSecrets` for authentication.
* [External with certs](https://blog.cloudhelix.io/using-a-private-docker-registry-with-kubernetes-f8d5f6b8f646). Similar requirement for secrets in pod specs.
* As a [pod in the cluster](https://ruediste.github.io/cloud/2017/02/23/docker-registry-on-gke.html). I think you need a tunnel to the remote on port 5000 as well.

### Google Container Registry

Every project has a private registry, and the GKE cluster has access to it by default. It is located at `gcr.io` and the image tag format to use is `gcr.io/<project-name>/<tag>`. You can extract the project name using `gcloud`:

```
$ export GCP_PROJECT=`gcloud config list --format 'value(core.project)'`
$ docker build -t gcr.io/$GCP_PROJECT/demo .
$ gcloud docker -- push gcr.io/$GCP_PROJECT/demo
```

If you write your k8s YAML by hand it would still need to have the project id hard-coded in it, so it might be better to use a tool to generate or manage the deployments.  Example a [simple client-side template engine](https://github.com/shyiko/kubetpl), or just UNIX stuff, e.g.

```
$ eval "echo \"$(cat encode.yaml)\"" | kubectl apply -f -
```

Images in the project registry can be managed (and deleted) in the GCP console, or via APIs.

### Using GCR From Vanilla Docker

Instead of `gcloud docker ...` (which I always forget to do) you can use a utility called `docker-credential-gcr` to set up the docker environment to just send `docker push` to GCR automatically:

```
$ curl -L https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v1.4.3/docker-credential-gcr_linux_amd64-1.4.3.tar.gz | (cd ~/bin; tar -zxvf -)
$ docker-credential-gcr configure-docker
$ docker push gcr.io/$GCP_PROJECT/demo
```

This last step actually installs "credHelpers" in your `~/.docker/config.json` (son it's permanent). It also slows down all docker builds (sigh) - see https://github.com/GoogleCloudPlatform/docker-credential-gcr/issues/11. You can speed it up a bit by pruning the "credHelpers" to just `gcr.io`. 

## Curl

```
$ kubectl run -it --image=tutum/curl client --restart=Never
root@client:/# curl -v ...
```

in istio:

```
$ kubectl run -it --image=tutum/curl client --restart=Never --overrides='{"apiVersion": "v1", "metadata":{"annotations": {"sidecar.istio.io/inject": "true"}}}'
root@client:/# curl -v tick-channel.default.svc.cluster.local -d foo -H "Content-Type: text/plain"
```

(possibly add `"traffic.sidecar.istio.io/includeOutboundIPRanges": "*"` as well, but it doesn't seem to need it). It's hard to kill it. You have to `kubectl delete pod client --force --grace-period=0`.

## Isolated Networks

Create an isolated network:


```
$ docker network create --driver=bridge --internal=true isolated
$ docker run --net=isolated -it tutum/curl
# curl google.com
 ... times out
```

Run a Maven build in an isolated container:

```
$ docker run --net=isolated -v `pwd`:/app -w /app -it openjdk:8-jdk-alpine /bin/sh
# ./mvnw package
```

(fails after a very long timeout).

Set up a nexus mirror and connect it to the isolated network:

```
$ docker run --name nexus -p 8081:8081 sonatype/nexus3
$ docker network connect isolated nexus
```

and point the Maven build at the mirror:

```
# sed -i -e 's,https://repo1.maven.org/maven2,http://nexus:8081/repository/maven-central,' .mvn/wrapper/maven-wrapper.properties
# mkdir -p ~/.m2
# cat > ~/.m2/settings.xml
<settings 
    xmlns="http://maven.apache.org/SETTINGS/1.0.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <mirrors>
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <name>Local Nexus Sonatype  Repository Mirror</name>
            <url>http://nexus:8081/repository/maven-central/</url>
        </mirror>
    </mirrors>
</settings>
# ./mvnw package
```

Works!

## Multistage Build

```
FROM openjdk:8-alpine as build
VOLUME /root/.m2
COPY pom.xml /app/pom.xml
COPY src /app/src
COPY .mvn /app/.mvn
COPY mvnw /app/mvnw
WORKDIR /app
RUN ./mvnw clean install

FROM openjdk:8-alpine
VOLUME /tmp
COPY --from=build /app/target/dependency/BOOT-INF/lib /app/lib
COPY --from=build /app/target/dependency/META-INF /app/META-INF
COPY --from=build /app/target/dependency/BOOT-INF/classes /app
ENTRYPOINT ["java","-Xmx128m","-Djava.security.egd=file:/dev/./urandom","-XX:TieredStopAtLevel=1","-noverify","-cp","app:app/lib/*","com.example.demo.Uppercase"]
```

Issue is that the `/root/.m2` volume is not the same between builds, so there is no cache.

## Quick Bootstrap Kubernetes Service

Create container and deployment:

```
$ docker build -t gcr.io/cf-sandbox-dsyer/demo .
$ mkdir k8s
$ kubectl create deployment demo --image=gcr.io/cf-sandbox-dsyer/demo --dry-run -o=yaml > k8s/deployment.yaml
$ echo --- > k8s/deployment.yaml
$ kubectl create service clusterip demo --tcp=8080:8080 --dry-run -o=yaml >> k8s/deployment.yaml
... edit YAML to taste
$ kubectl apply -f k8s/deployment.yaml
$ kubectl port-forward svc/demo 8080:8080
$ curl localhost:8080
Hello World!
```

## Quick and Dirty Ingress

Simple port forwarding for localhost:

```
$ kubectl create service clusterip demo --tcp=8080:8080
$ $ kubectl port-forward svc/demo 8080:8080
$ curl localhost:8080
Hello World!
```

Public ingress via `ngrok`:

```
$ kubectl run --restart=Never -t -i --rm ngrok --image=gcr.io/kuar-demo/ngrok -- http demo:8080
```

`ngrok` starts and announces a public http and https service that connects to your "demo" service.

## Using NodePort Services in Kind

> NOTE: It's easier TBH to just use `ClusterIP` and `kubectl port-forward` to connect to a service in a kind cluster.

Kind only exposes one port in the cluster to the host machine (the kubernetes API). If you deploy a service in the cluster with `type: NodePort` it will not be accessible unless you tunnel to it. You can do that with `alpine/socat`:

```
$ kubectl get service dev-app
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/dev-app      NodePort    10.97.254.57     <none>        8080:31672/TCP   22m

$ docker run -p 127.0.0.1:8080:80 --link kind-control-plane:target alpine/socat tcp-listen:80,fork,reuseaddr tcp-connect:target:31672
```

The service is now available on the host on port 8080. You can extract that ephemeral port using `kubectl`:

```
$ kubectl get service dev-app -o=jsonpath="{.spec.ports[?(@.port == 8080)].nodePort}"
31672
```
