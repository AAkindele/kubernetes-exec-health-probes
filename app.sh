#!/bin/sh

# how long to wait between file updates
sleep_seconds=$1
if [ -z "$sleep_seconds" ]
then
  echo "sleep_seconds is missing"
  exit 1
fi
echo "sleep_seconds - $sleep_seconds"

# start up wait time. default to 1 second if missing
start_delay_seconds="${2:-1}"
echo "start_delay_seconds - $start_delay_seconds"

echo "sleeping for $start_delay_seconds seconds"
sleep $start_delay_seconds

while true
do
  # update the file before doing work
  echo "$(date -u +"%FT%TZ") updating /tmp/health.txt"
  touch /tmp/health.txt

  # do work
  echo "sleeping for $sleep_seconds seconds"
  sleep $sleep_seconds
done
