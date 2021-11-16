#!/bin/bash

AWS_ROOT='https://apt.corretto.aws'
KEY_URL="${AWS_ROOT}/corretto.key"
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
echo "deb ${AWS_ROOT} stable main" > "${APT_DIR}/corretto.list"

if [[ $? -ne 0 ]]; then
    echo '[ERROR] Failed to create entry'
    exit 2
fi

echo 'NOTE: Please run `apt update` to pick up these changes'

exit 0
