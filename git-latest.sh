#!/bin/bash -e

# https://github.com/screwdriver-cd/gitversion/releases
if [ "$SCREWDRIVER" == true ]; then
  GIT_VERSION=/opt/sd/gitversion
else
  GIT_VERSION=/tmp/gitversion
  if [ ! -f "$GIT_VERSION" ] ; then
    echo Downloading gitversion
    wget -q -O - https://github.com/screwdriver-cd/gitversion/releases/latest \
      | egrep -o '/screwdriver-cd/gitversion/releases/download/v[0-9.]*/gitversion_linux_amd64' \
      | wget --base=http://github.com/ -i - -O /tmp/gitversion
    chmod +x $GIT_VERSION
  fi
fi
echo Finding version
$GIT_VERSION --prefix v show | tee VERSION
