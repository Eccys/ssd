#!/bin/bash

# File path
OUTPUT_FILE="/opt/tmp"

# Function to add cron job
add_cron_job() {
  (crontab -l 2>/dev/null; echo "* * * * * /bin/bash $0") | crontab -
  echo "Cron job added to run this script every minute."
}

# Check for -auto flag
if [[ "$1" == "-auto" ]]; then
  add_cron_job
  exit 0
fi

# Start time
start_time=$(date +%s)

# Run the write process for 60 seconds
while [ $(($(date +%s) - $start_time)) -lt 60 ]; do
  # Start two dd operations in parallel
  dd if=/dev/zero of=${OUTPUT_FILE}_1 bs=1G count=1 oflag=sync status=none &
  dd if=/dev/zero of=${OUTPUT_FILE}_2 bs=1G count=1 oflag=sync status=none &
  dd if=/dev/zero of=${OUTPUT_FILE}_3 bs=1G count=1 oflag=sync status=none &
  dd if=/dev/zero of=${OUTPUT_FILE}_4 bs=1G count=1 oflag=sync status=none &
  dd if=/dev/zero of=${OUTPUT_FILE}_5 bs=1G count=1 oflag=sync status=none &

  # Wait for both operations to complete
  wait
done

echo "Data write complete for this minute."
