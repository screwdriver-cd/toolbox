#!/bin/bash -e

GIT_VERSION=/tmp/gitversion
if [ ! -f "$GIT_VERSION" ] ; then
    echo Downloading gitversion
    GIT_URI_PATH=$(wget -q -O - https://github.com/screwdriver-cd/gitversion/releases/latest | egrep -o '/screwdriver-cd/gitversion/releases/download/v[0-9.]*/gitversion_linux_amd64')
    wget -O $GIT_VERSION http://github.com/$GIT_URI_PATH
    chmod +x $GIT_VERSION
fi

echo Finding version
$GIT_VERSION --prefix v show | tee VERSION
