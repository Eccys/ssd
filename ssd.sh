#!/bin/bash

OUTPUT_DIR="/opt/tmp"
OUTPUT_PREFIX="tbw"
COUNT=102400  # 100MB per file (102400 * 1024 bytes)
MAX_PARALLEL=5  # Number of parallel dd commands
DURATION=60  # Run for 60 seconds

# Ensure output directory exists and is writable
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR" || { echo "Error: Cannot create directory $OUTPUT_DIR"; exit 1; }
fi
if [[ ! -w "$OUTPUT_DIR" ]]; then
    echo "Error: Directory $OUTPUT_DIR is not writable"
    exit 1
fi

add_cron_job() {
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "$(realpath "$0") -auto"; then
        echo "Cron job already exists."
        return 0
    fi

    # Add cron job
    (
        crontab -l 2>/dev/null
        echo "* * * * * /bin/bash $(realpath "$0") -auto"
    ) | crontab -
    if [[ $? -eq 0 ]]; then
        echo "Cron job added to run this script every minute."
    else
        echo "Failed to add cron job."
        exit 1
    fi
}

if [[ "$1" == "-cron" ]]; then
    add_cron_job
    exit 0
fi

# Track total bytes written
total_bytes=0

# Run for 60 seconds
start_time=$(date +%s)
end_time=$((start_time + DURATION))

while [ $(date +%s) -lt $end_time ]; do
    # Start up to MAX_PARALLEL dd commands
    for i in $(seq 1 "$MAX_PARALLEL"); do
        output_file="${OUTPUT_DIR}/${OUTPUT_PREFIX}_${i}_$(date +%s)_$RANDOM"
        dd if=/dev/zero of="$output_file" bs=1024 count="$COUNT" status=none 2>/tmp/dd_error.log &
        pids[$i]=$!
        ((total_bytes += COUNT * 1024))  # Track bytes written
    done

    # Wait for this batch of dd commands to complete
    for i in $(seq 1 "$MAX_PARALLEL"); do
        if ! wait "${pids[$i]}"; then
            echo "Error in dd command for file $output_file. Check /tmp/dd_error.log"
            exit 1
        fi
    done
done

# Report total data written
echo "Wrote $((total_bytes / 1048576)) MB to $OUTPUT_DIR"

# Delete files if running with -auto
if [[ "$1" == "-auto" ]]; then
    echo "Running in -auto mode, deleting created files."
    find "$OUTPUT_DIR" -name "${OUTPUT_PREFIX}_*" -type f -delete
    if [[ $? -eq 0 ]]; then
        echo "Successfully deleted files."
    else
        echo "Failed to delete files."
    fi
fi

exit 0
