#!/bin/bash -e

# https://github.com/screwdriver-cd/gitversion/releases
GIT_VERSION=/opt/sd/gitversion
echo Finding version
$GIT_VERSION --prefix v show | tee VERSION
