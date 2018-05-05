#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root or via sudo"
    exit 1
fi

DEB_LOCATION="https://discordapp.com/api/download?platform=linux&format=deb"

SCRIPTNAME=$(basename $0)
TMPDIR="/tmp/${SCRIPTNAME}.${$}"

function tear_down {
    local rc=0
    if [[ -d "$TMPDIR" ]]; then
        rm -rf "${TMPDIR}"
        rc=$?

        [[ $rc -ne 0 ]] && echo "WARNING: Failed to cleanup ${TMPDIR}"
    fi

    return $rc
}

echo "Creating temporary working directory ${TMPDIR}"
mkdir "${TMPDIR}" || exit $?

# Now that the directory has been created successfully, create the traps.
trap tear_down EXIT
trap tear_down INT
trap tear_down TERM

echo "Fetching Discord debian archive"

discordDeb="${TMPDIR}/Discord.deb"

wget --show-progress -O "${discordDeb}" "${DEB_LOCATION}" || exit $?

echo "Executing install of archive"
dpkg -i "${discordDeb}"

exitCode=$?
if [[ $exitCode -ne 0 ]]; then
    echo "Installation failed; this is normal if required dependencies are not installed"
    echo "Attempting to resolve installation failure"
    apt install -f -y
    exitCode=$?

    if [[ $exitCode -ne 0 ]]; then
        echo "ERROR: Unable to resolve installation failure"
    else
        echo "Retrying Discord install"
        dpkg -i "${discordDeb}"
        exitCode=$?
    fi
fi

if [[ $exitCode -eq 0 ]]; then
    echo "Discord installation successful"
else
    echo "ERROR: Discord installation has failed"
fi

exit $exitCode
