#!/usr/bin/bash -e

KUBECTL_LATEST=$(curl -sL https://storage.googleapis.com/kubernetes-release/release/stable.txt)
KUBECTL_HASH=$(curl -sL "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST}/bin/linux/amd64/kubectl.sha256")

TMP_DIR=$(mktemp -d)
cd ${TMP_DIR}

echo "Getting kubectl ${KUBECTL_LATEST}"
curl -sLO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_LATEST}/bin/linux/amd64/kubectl"
echo "${KUBECTL_HASH} kubectl" > hash

if sha256sum -c hash; then 
    chmod +x kubectl
    mv kubectl /usr/bin/kubectl
else
    echo "kubectl checksum mismatch"
fi

cd ${OLDPWD}
rm -rf ${TMP_DIR}