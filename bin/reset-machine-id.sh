#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
    echo "This must be run as root or via sudo."
    exit 1
fi

echo "Removing current machine-id..."
rm -f /etc/machine-id || exit $?

echo "Using systemd to generate a new machine-id..."
systemd-machine-id-setup || exit $?

# Is netplan installed?
which netplan > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo "Updating netplan..."
    netplan apply || exit $?
else
    echo "Unable to locate netplan; skipping netplan update."
fi

echo "WARN: Please reboot as soon as possible to apply these changes."

exit 0
