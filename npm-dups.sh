#!/bin/bash -e
# NPM_FILTER = Filter to reduce NPM dependencies to
if [ -z "$NPM_FILTER" ] ; then
  echo Unable to npm duplicate check, missing environment variables
  exit 2
fi

echo Searching for filtered packages
npm ls | grep $NPM_FILTER | tee /tmp/npm.filter

echo Reducing to duplicate packages
cat /tmp/npm.filter | sed -E -e 's/[^a-zA-Z_-]//g' | sort | uniq -iD > /tmp/npm.dups
if [ -s /tmp/npm.dups ] ; then
  echo Duplicate packages found, failing build
  exit 1
else
  echo No duplicate packages found
fi
