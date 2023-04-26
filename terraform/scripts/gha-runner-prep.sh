#!/usr/bin/env bash
set -e

# ./gha-runner-prep.sh \
#     --archive https://github.com/actions/runner/releases/download/v2.262.1/actions-runner-linux-x64-2.262.1.tar.gz \
#     --url https://github.com/xxxxx/xxxxxx \
#     --token XXXXXXXXX \
#     --prefix shared_gha-runner

while [ "${1}" != "" ]; do
    case ${1} in
        --archive ) shift; RUNNER_ARCHIVE="${1}";;
        --archive-hash ) shift; RUNNER_ARCHIVE_HASH="${1}";;
        --url ) shift; RUNNER_URL="${1}";;
        --token ) shift; RUNNER_TOKEN="${1}";;
        --prefix ) shift; RUNNER_PREFIX="${1}";;
        --labels ) shift; RUNNER_LABELS="${1}";;
    esac
    shift
done

export DEBIAN_FRONTEND=noninteractive


# GHA Dependencies
echo ""
echo "Installing dependencies"
apt-get update
apt-get install --yes --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common \
    liblttng-ust0 \
    libkrb5-3 \
    zlib1g \
    libssl1.1 \
    libicu66 \
    git \
    python3-pip


# Install docker
echo ""
echo "Installing Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install --yes \
    docker-ce \
    docker-ce-cli \
    containerd.io
pip3 install docker-compose


# Install ECR Helper
echo ""
echo "Installing AWS ECR Helper"
curl -sL https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.4.0/linux-amd64/docker-credential-ecr-login > /usr/local/bin/docker-credential-ecr-login
chmod +x /usr/local/bin/docker-credential-ecr-login
mkdir -p /root/.docker /home/ubuntu/.docker
echo '{ "credsStore": "ecr-login" }' > /root/.docker/config.json
echo '{ "credsStore": "ecr-login" }' > /home/ubuntu/.docker/config.json
chown -R ubuntu:ubuntu /home/ubuntu/.docker


# Install GHA agent
echo ""
echo "Installing Github Actions Runner"
TEMPDIR=$(mktemp -d)
curl -sL ${RUNNER_ARCHIVE} > ${TEMPDIR}/actions-runner.tar.gz
echo "Checking archive hash"
echo "${RUNNER_ARCHIVE_HASH}  ${TEMPDIR}/actions-runner.tar.gz" | shasum -a 256 -c
mkdir -p ${TEMPDIR}/github-runner/
tar xzf ${TEMPDIR}/actions-runner.tar.gz -C ${TEMPDIR}/github-runner/

CORE_COUNT=$(nproc)
RUNNER_COUNT=$((${CORE_COUNT} - (${CORE_COUNT} / 3) - 1))
export RUNNER_ALLOW_RUNASROOT=1

for i in $(seq 1 ${RUNNER_COUNT}); do
    cp -rp ${TEMPDIR}/github-runner/ /opt/github-runner-${i}/
    cd /opt/github-runner-${i}/
   
    if [ -z ${RUNNER_LABELS} ]; then
        ./config.sh \
            --url ${RUNNER_URL} \
            --token ${RUNNER_TOKEN} \
            --name "${RUNNER_PREFIX}-$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 16 | head -n 1)" \
            --unattended
    else
        ./config.sh \
            --url ${RUNNER_URL} \
            --token ${RUNNER_TOKEN} \
            --name "${RUNNER_PREFIX}-$(cat /dev/urandom | tr -dc 'a-zA-Z' | fold -w 16 | head -n 1)" \
            --labels ${RUNNER_LABELS} \
            --unattended
    fi
    ./svc.sh install
    ./svc.sh start
done

rm -rf ${TEMPDIR}

echo ""
echo "Finished."
