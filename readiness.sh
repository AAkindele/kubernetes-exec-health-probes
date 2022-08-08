set -e

# file used to check of activity
health_file="$1"
if [ -z "$health_file" ]
then
  echo "health_file is missing"
  exit 1
fi
echo "health_file - $health_file"

cat $health_file
