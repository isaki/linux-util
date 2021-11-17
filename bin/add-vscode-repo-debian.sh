#!/bin/bash

VSCODE_ROOT='https://packages.microsoft.com'
REPO_URL="${VSCODE_ROOT}/repos/code"
KEY_URL="${VSCODE_ROOT}/keys/microsoft.asc"
APT_DIR='/etc/apt/sources.list.d'

if [[ $(id -u) -ne 0 ]]; then
    echo 'This must be run as root or via sudo'
    exit -1
fi

echo "Adding key from ${KEY_URL}"

wget -O- "${KEY_URL}" | apt-key add - 

if [[ $? -ne 0 ]]; then
    echo '[ERROR] Keyring modification failed'
    exit 1
fi

echo "Creating entry in ${APT_DIR}"
echo "deb [arch=amd64,arm64,armhf] ${REPO_URL} stable main" > "${APT_DIR}/vscode.list"

if [[ $? -ne 0 ]]; then
    echo '[ERROR] Failed to create entry'
    exit 2
fi

echo 'NOTE: Please run `apt update` to pick up these changes'

exit 0
