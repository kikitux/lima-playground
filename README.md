# lima-playground

## how to use this repo

- clone this repo
```
git clone https://github.com/kikitux/lima-playground.git
```

- change directory
```
cd lima-playground
```

- install pre requirements
```
bash ./setup.sh
```

This will install on macos or linux the following:
- lima
- kubectl
- oc ( Openshift Client )

### use any of the projects

- change directory
```
cd lima-<name>
```

- run the instance
```
./run.sh
```

- delete the instance
```
./run.sh delete
```


## whats included

### generic
- [lima-aarch64](lima-aarch64) a vm set for aarch64, will work on x86_64
- [lima-x86_64](lima-x86_64) a vm set for x86_64, will work on aarch64

### container
- [lima-docker](lima-docker) a vm using docker template from lima
- [lima-podman](lima-podman) a vm using podman template from lima

### kubernetes
- [lima-k8s](lima-k8s) a vm using k8s template from lima
- [lima-kind](lima-kind) a vm using latest kind

### microshift
- [lima-microshift-minc](lima-microshift-minc) a vm using minc ( microshift in container )
- [lima-microshift-rpm](lima-microshift-rpm) a vm using microshift rpms

