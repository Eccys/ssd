#!/bin/bash

OUTPUT_FILE="/opt/tmp"

add_cron_job() {
    (
        crontab -l 2>/dev/null
        echo "* * * * * /bin/bash $(realpath $0) -auto"
    ) | crontab -
    if [[ $? -eq 0 ]]; then
        echo "Cron job added to run this script every minute."
    else
        echo "Failed to add cron job."
    fi
}

if [[ "$1" == "-auto" ]]; then
    add_cron_job
    exit 0
fi

start_time=$(date +%s)

while [ $(($(date +%s) - $start_time)) -lt 59 ]; do
    for i in {1..5}; do
        dd if=/dev/zero of="${OUTPUT_FILE}_$i" bs=1024 count=1024 oflag=direct status=none &&
    done
    wait
done

echo "Data write complete for this minute."
