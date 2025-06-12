#!/bin/bash

OUTPUT_DIR="/opt/tmp"
OUTPUT_PREFIX="tbw"
COUNT=102400  # 100MB per file (102400 * 1024 bytes)
NUM_FILES=5   # Total 500MB per minute

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

# Delete old files if running with -auto
if [[ "$1" == "-auto" ]]; then
    find "$OUTPUT_DIR" -name "${OUTPUT_PREFIX}_*" -type f -delete
fi

# Write files to exhaust TBW
for i in $(seq 1 "$NUM_FILES"); do
    output_file="${OUTPUT_DIR}/${OUTPUT_PREFIX}_${i}_$(date +%s)"
    dd if=/dev/zero of="$output_file" bs=1024 count="$COUNT" status=none 2>/tmp/dd_error.log &
    if [[ $? -ne 0 ]]; then
        echo "Error in dd command for file $output_file. Check /tmp/dd_error.log"
        exit 1
    fi
done

# Wait for all dd commands to complete
wait

echo "Wrote $((NUM_FILES * COUNT / 1024)) MB to $OUTPUT_DIR"

exit 0
