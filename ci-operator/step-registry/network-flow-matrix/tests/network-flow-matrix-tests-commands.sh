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

source $HOME/golang-1.22.4
echo "Go version: $(go version)"
git clone https://github.com/openshift-kni/commatrix ${SHARED_DIR}/commatrix
pushd ${SHARED_DIR}/commatrix || exit
git checkout ${OC_BRANCH}
go mod vendor
make e2e-test
popd || exit
