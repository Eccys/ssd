#!/bin/bash

# If not running under caffeinate, re-launch the script with it.
# This prevents the system from sleeping while the script is running.
if ! pgrep -qf "caffeinate -i /bin/bash $0"; then
    echo "Relaunching under caffeinate to prevent sleep..."
    exec caffeinate -i /bin/bash "$0" "$@"
fi

OUTPUT_DIR="/opt/tmp"
OUTPUT_PREFIX="tbw"
COUNT=1048576  # 1GB per file (1048576 * 1024 bytes)
MAX_PARALLEL=$(($(sysctl -n hw.ncpu)))  # Run 2x the number of CPU cores
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

# Run for the specified duration
echo "Starting stress test for $DURATION seconds. Press Ctrl+C to stop."
echo "Parallel processes: $MAX_PARALLEL"
start_time=$(date +%s)
end_time=$((start_time + DURATION))
batch_num=1

while [ $(date +%s) -lt $end_time ]; do
    # Array to hold PIDs for this batch
    pids=()

    # Start up to MAX_PARALLEL dd commands
    for i in $(seq 1 "$MAX_PARALLEL"); do
        output_file="${OUTPUT_DIR}/${OUTPUT_PREFIX}_${i}_$(date +%s)_$RANDOM"
        dd if=/dev/urandom of="$output_file" bs=1024 count="$COUNT" oflag=direct status=none 2>/tmp/dd_error.log &
        pids+=($!)
        ((total_bytes += COUNT * 1024))  # Track bytes written
    done

    # Wait for this batch of dd commands to complete
    echo "[$(date +%H:%M:%S)] Starting Batch #$batch_num: Writing $((${#pids[@]} * COUNT / 1048576)) GB..."
    wait_error=0
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            echo "Error in a dd command. Check /tmp/dd_error.log"
            wait_error=1
        fi
    done

    echo "[$(date +%H:%M:%S)] Finished Batch #$batch_num."
    ((batch_num++))

    # Exit if there was an error in the batch
    if [ "$wait_error" -eq 1 ]; then
        echo "Exiting due to dd command failure."
        exit 1
    fi
done

# Report total data written
echo "Finished test."
echo "Wrote $((total_bytes / 1048576)) MB to $OUTPUT_DIR in $DURATION seconds."

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
