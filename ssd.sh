#!/bin/bash

# File path
OUTPUT_FILE="/opt/tmp"

# Start time
start_time=$(date +%s)

# Run the write process for 60 seconds
while [ $(($(date +%s) - $start_time)) -lt 60 ]; do
  # Write 1 GB of data filled with zeroes and overwrite the file
  dd if=/dev/zero of=$OUTPUT_FILE bs=1G count=1 oflag=sync status=none
done

echo "Data write complete for this minute."

