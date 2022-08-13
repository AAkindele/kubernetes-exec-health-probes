#!/bin/sh

set -e

# file used to check of activity
health_file="$1"
if [ -z "$health_file" ]
then
  echo "health_file argument is missing"
  exit 1
fi
echo "health_file - $health_file"

if [ ! -f "$health_file" ]
then
  echo "cannot find health file $health_file"
  exit 1
fi
