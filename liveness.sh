set -e

# how long the health file can go without being updated
threshold_seconds="$1"
if [ -z "$threshold_seconds" ]
then
  echo "threshold_seconds is missing"
  exit 1
fi
echo "threshold_seconds - $threshold_seconds"

# file used to check for active activity
health_file="$2"
if [ -z "$health_file" ]
then
  echo "health_file is missing"
  exit 1
fi
echo "health_file - $health_file"

# current time
current_time=`date +%s`
echo "current_time - $current_time"

# beginning of time range we're checking for activity
cutoff_time=$(($current_time - $threshold_seconds))
echo "cutoff_time - $cutoff_time"

# last time health file was updated
last_update=`stat $health_file --format "%Y"`
echo "last_update - $last_update"

# last update to health file is before the beginning of the required time range
if [ $last_update -lt $cutoff_time ]
then
  echo "Health file has not been updated within threshold."
  exit 1
fi

# last update to file is within the required time range
echo "Health file has been updated within threshold."
