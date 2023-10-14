#!/bin/sh

# how long to wait between file updates
sleep_seconds=$1
if [ -z "$sleep_seconds" ]
then
  echo "sleep_seconds is missing"
  exit 1
fi
echo "sleep_seconds - $sleep_seconds"

while true
do
  # update the file before doing work
  echo "$(date -u +"%FT%TZ") updating /tmp/health.txt"
  touch /tmp/health.txt

  # do work
  echo "sleeping for $sleep_seconds seconds"
  sleep "$sleep_seconds"
done
