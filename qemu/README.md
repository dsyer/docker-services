Scripts to set up and run a qemu image.

* Run `init.sh` and follow instructions to install Alpine on the VM. Remember the root password.
* Log off, go to the monitor (`Alt-Ctrl-2`) and quit `q`.
* Start again with `init.sh` and it will boot from the disk image intead of CD.
* Any time you get to a savepoint, go to the monitor and `savevm init`.

> NOTE: Instead of the manual process above you can use a script from https://github.com/alpinelinux/alpine-make-vm-image.

At this point you can iterate until you have a basic VM image you can run apps from. 
Things to do maybe:

* Enable `PermitRootLogin` in `/etc/ssh/sshd_config` and `service sshd restart`
* Comment oput the "community" entry in `/etc/apk/repositories`
* Install JVM with `apk add openjdk8`
* Add `JAVA_HOME` env var and `$JAVA_HOME/bin` to `PATH` in `/etc/profile.d/java.sh`

If you open up `sshd` then you can `ssh -p 2222 root@192.168.2.19` (your local IP address) or `scp -P 2222 app.jar root@192.168.2.19:~` (for instance).

Once you have a base image ready, copy or rename the `alpine.qcow` disk image to `disk.qcow` and use `run.sh` to run it headless. 

* Login using `ssh` from the host and get the app running.
* Go into the Qemu monitor (`Ctrl-A C` toggles between monitor and VM)
* Create a snapshot: `savevm init`