# Helm-hadoop

## Usage

### macOS

#### Prerequisites
```shell
brew install qemu socket_vmnet helm
```

#### Setup
```shell
# Start minikube
minikube start --driver qemu --network socket_vmnet --cpus "$(($(nproc) / 2))" --memory "$(nproc)g"

# Build the image and load it to minikube
docker/build_image.sh

helm install --name-template=hbase .
```

#### Access Services
```shell
# Set route up
sudo route -n delete 10.244.0.0/16
sudo route -n add 10.244.0.0/16 "$(minikube ip)"

# Don't kill this process
minikube tunnel
```

#### Test
```shell
ping hm-0.hmaster.default.svc.cluster.local

curl -L http://hm-0.hmaster.default.svc.cluster.local:16010/
```

### Linux

#### Prerequisites

* docker ([https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/))
* helm ([https://github.com/helm/helm/releases/latest](https://github.com/helm/helm/releases/latest))

#### Setup
```shell
# Start minikube
minikube start --driver docker --cpus "$(($(nproc) / 2))" --memory "$(nproc)g"

# Build the image and load it to minikube
docker/build_image.sh

helm install --name-template=hadoop .
```

#### Access Services
```shell
# Set DNS up
sudo resolvectl dns "$(ip route | grep "$(minikube ip)" | head -1 | awk '{print $NF}')" \
    "$(kubectl get -n kube-system service --no-headers | awk '{print $3}')"
sudo resolvectl domain "$(ip route | grep "$(minikube ip)" | head -1 | awk '{print $NF}')" \
    cluster.local

# Set route up
sudo route del -net 10.244.0.0 netmask 255.255.0.0
sudo route add -net 10.244.0.0 netmask 255.255.0.0 gw "$(minikube ip)"

# Don't kill this process
minikube tunnel
```

#### Test
```shell
ping hm-0.hmaster.default.svc.cluster.local

curl -L http://hm-0.hmaster.default.svc.cluster.local:16010/
```
