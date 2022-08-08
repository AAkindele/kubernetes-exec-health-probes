# TOdO: pass in top 2 vars as params

# how long the file can go without being updated
threshold_seconds="10"
echo "threshold_seconds - $threshold_seconds"

# file used to check of activity
health_file="health.txt"
echo "health_file - $health_file"

# current time
current_time=`date +%s`
echo "current_time - $current_time"

# beginning of time range we're check
cutoff_time=$(($current_time - $threshold_seconds))
echo "cutoff_time - $cutoff_time"

# last time file was updated
last_update=`stat $health_file --format "%Y"`
echo "last_update - $last_update"

# last update to file is before the beginning of the required time range
if [ $last_update -lt $cutoff_time ]
then
  echo "File has not been updated within threshold."
  exit 1
fi

# last update to file is within the required time range
echo "File has been updated within threshold."
