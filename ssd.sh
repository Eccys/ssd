#!/bin/bash

OUTPUT_FILE="/opt/tmp"

add_cron_job() {
  (crontab -l 2>/dev/null; echo "* * * * * /bin/bash $0") | crontab -
  echo "Cron job added to run this script every minute."
}

if [[ "$1" == "-auto" ]]; then
  add_cron_job
  exit 0
fi

start_time=$(date +%s)

while [ $(($(date +%s) - $start_time)) -lt 59 ]; do
    dd if=/dev/zero of=${OUTPUT_FILE}_1 bs=1G count=1 oflag=sync status=none &
    dd if=/dev/zero of=${OUTPUT_FILE}_2 bs=1G count=1 oflag=sync status=none &
    dd if=/dev/zero of=${OUTPUT_FILE}_3 bs=1G count=1 oflag=sync status=none &
    dd if=/dev/zero of=${OUTPUT_FILE}_4 bs=1G count=1 oflag=sync status=none &
    dd if=/dev/zero of=${OUTPUT_FILE}_5 bs=1G count=1 oflag=sync status=none
  wait
done

echo "Data write complete for this minute."
