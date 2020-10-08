#!/bin/bash

export KUBEVIRTCI_TAG=$(date +"%y%m%d%H%M")-$(git rev-parse --short HEAD)

# Build gocli
(cd cluster-provision/gocli && make container)
docker tag kubevirtci/gocli kubevirtci/gocli:${KUBEVIRTCI_TAG}

# Provision all base images
(cd cluster-provision/centos7 && ./build.sh)
(cd cluster-provision/centos8 && ./build.sh)

# Provision all clusters
for i in $(find cluster-provision/k8s/* -maxdepth 0 -type d -printf '%f\n'); do
    echo  "cluster-provision/gocli/build/cli provision cluster-provision/k8s/$i"
    docker tag kubveirtci/k8s-$i kubveirtci/k8s-$i:${KUBEVIRTCI_TAG}
done

# Push all images
docker push kubevirtci/gocli:${KUBEVIRTCI_TAG}
for i in $(find cluster-provision/k8s/* -maxdepth 0 -type d -printf '%f\n'); do
    docker push kubveirtci/k8s-$i:${KUBEVIRTCI_TAG}
done

git tag ${KUBEVIRTCI_TAG}
git push origin ${KUBEVIRTCI_TAG}
