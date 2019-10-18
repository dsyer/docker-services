When you

```
$ docker-compose up
```

it writes a `k8s` config file in the current directory.

So you can 

```
$ kubectl --kubeconfig kubeconfig.yaml get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   2m17s
```

Also you can copy the `kubeconfig.yaml` into `~/.kube/config` (don't overwrite it, copy the sections from the YAML individually), and then

```
$ kubectl use-context default
$ kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   2m17s
```

To clean up you need to delete the volume (specified in the `docker-compose.yml`):

```
$ docker-compose rm -fvs
$ docker volume rm k3s_k3s-server 
```

If you don't delete the volume you don't have to change the `kubeconfig.yaml` when you run again, but you might have some cluster state from the previous run.

The cluster has an ingress controller using [Traefik](https://docs.traefik.io/user-guide/kubernetes/):

```
$ kubectl get service --namespace=kube-system
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
kube-dns   ClusterIP      10.43.0.10     <none>        53/UDP,53/TCP,9153/TCP       11m
traefik    LoadBalancer   10.43.37.208   172.19.0.3    80:31193/TCP,443:30831/TCP   9m8s
$ curl 172.19.0.3 -v
404 page not found
```

so deploy a "doubler" service and expose it as a service on port 80:

```
kind: Service
apiVersion: v1
metadata:
  name: doubler
  labels:
    app: doubler
spec:
  ports:
  - name: http
    port: 80
    targetPort: 8080
  selector:
    app: doubler
```

and then set up an ingress rule:

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: doubler
spec:
  rules:
  - host: doubler
    http:
      paths:
      - path: /
        backend:
          serviceName: doubler
          servicePort: 80

```

and you can curl it on the traefik endpoint:

```
$ curl 172.19.0.3 -H "Host: doubler" -H "Content-Type: text/plain" -d 30
60
```
