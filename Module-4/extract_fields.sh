#!/bin/bash

# Check for input file
if [ $# -ne 1 ]; then
    echo "Usage: $0 input_file"
    exit 1
fi

INPUT="$1"
OUTPUT="output.txt"

# Clearing the old output file
> "$OUTPUT"

# Empty Variables
frame_time=""
fc_type=""
fc_subtype=""

# Read file line by line
while read -r line
do
    # Extarct frame.time
    if echo "$line" | grep -q '"frame.time"'; then
        frame_time=$(echo "$line" | sed 's/.*"frame.time": "\(.*\)".*/\1/')
    fi

    # Extract wlan.fc.type
    if echo "$line" | grep -q '"wlan.fc.type"'; then
        fc_type=$(echo "$line" | sed 's/.*"wlan.fc.type": "\(.*\)".*/\1/')
    fi

    # Extract wlan.fc.subtype
    if echo "$line" | grep -q '"wlan.fc.subtype"'; then
        fc_subtype=$(echo "$line" | sed 's/.*"wlan.fc.subtype": "\(.*\)".*/\1/')
    fi

    # If all found, write to output
    if [[ -n "$frame_time" && -n "$fc_type" && -n "$fc_subtype" ]]; then

        echo "\"frame.time\": \"$frame_time\"," >> "$OUTPUT"
        echo "\"wlan.fc.type\": \"$fc_type\"," >> "$OUTPUT"
        echo "\"wlan.fc.subtype\": \"$fc_subtype\"" >> "$OUTPUT"
        echo "" >> "$OUTPUT"

        # Reset
        frame_time=""
        fc_type=""
        fc_subtype=""
    fi

done < "$INPUT"

echo "Process completed. Output saved in output.txt"
