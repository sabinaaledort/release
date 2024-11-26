#!/bin/bash

# Extract and format the oc version to branch
extract_version() {
  version=$(oc version | grep "Server Version:" | awk '{print $3}')
  major=$(echo "$version" | cut -d '.' -f 1)
  minor=$(echo "$version" | cut -d '.' -f 2)
  oc_branch="release-$major.$minor"
  echo "$oc_branch"
}
OC_BRANCH=$(extract_version)

COMMATRIX_DIR="${SHARED_DIR}/commatrix"
ADDITIONAL_NFTABLES_RULES_MASTER_PATH="${COMMATRIX_DIR}/additional-nftables-rules-master"

ADDITIONAL_NFTABLES_RULES_MASTER="
# Allow host level services dynamic port range
tcp dport 9000-9999 accept
udp dport 9000-9999 accept
# Allow Kubernetes node ports dynamic port range
tcp dport 30000-32767 accept
udp dport 30000-32767 accept
# Keep port open for origin test
# https://github.com/openshift/origin/blob/master/vendor/k8s.io/kubernetes/test/e2e/network/service.go#L2622
tcp dport 10180 accept
udp dport 10180 accept
# Keep port open for origin test
# https://github.com/openshift/origin/blob/master/vendor/k8s.io/kubernetes/test/e2e/network/service.go#L2724
tcp dport 80 accept
udp dport 80 accept"

source $HOME/golang-1.22.4
echo "Go version: $(go version)"
git clone https://github.com/openshift-kni/commatrix ${COMMATRIX_DIR}
pushd ${COMMATRIX_DIR} || exit
git checkout ${OC_BRANCH}
go mod vendor
echo "${ADDITIONAL_NFTABLES_RULES_MASTER}" > ${ADDITIONAL_NFTABLES_RULES_MASTER_PATH}
EXTRA_NFTABLES_MASTER_FILE="${ADDITIONAL_NFTABLES_RULES_MASTER_PATH}" make e2e-test
popd || exit
