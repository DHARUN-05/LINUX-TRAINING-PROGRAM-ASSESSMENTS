#!/bin/bash

# Check if 3 arguments are given
if [ $# -ne 3 ]; then
    echo "Usage: $0 <source_dir> <backup_dir> <extension>"
    exit 1
fi

# Assign arguments
SOURCE_DIR="$1"
BACKUP_DIR="$2"
EXT="$3"

# Initialize backup count
export BACKUP_COUNT=0
TOTAL_SIZE=0

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Create backup directory if not exists
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory."
        exit 1
    fi
fi

# Enable nullglob (avoids error if no files found)
shopt -s nullglob

# Store matching files in array
FILES=("$SOURCE_DIR"/*"$EXT")

# Check if no matching files
if [ ${#FILES[@]} -eq 0 ]; then
    echo "No files found with extension $EXT"
    exit 1
fi

echo "Files to be backed up:"

# Print file names and sizes
for file in "${FILES[@]}" ; do
    size=$(stat -c %s "$file")
    echo "$(basename "$file") - $size bytes"
done

echo "Starting backup..."

# Backup process
for file in "${FILES[@]}" ; do
    filename=$(basename "$file")
    dest="$BACKUP_DIR/$filename"

    size=$(stat -c %s "$file")

    # If file exists in backup
    if [ -f "$dest" ]; then

        # Compare timestamps
        if [ "$file" -nt "$dest" ]; then
            cp "$file" "$dest"
            echo "Updated: $filename"
        else
            echo "Skipped (newer exists): $filename"
            continue
        fi

    else
        cp "$file" "$dest"
        echo "Copied: $filename"
    fi

    BACKUP_COUNT=$((BACKUP_COUNT + 1))
    TOTAL_SIZE=$((TOTAL_SIZE + size))

done

# Create report
REPORT_FILE="$BACKUP_DIR/backup_report.log"

echo "Backup Summary Report" > "$REPORT_FILE"
echo "---------------------" >> "$REPORT_FILE"
echo "Total files processed: $BACKUP_COUNT" >> "$REPORT_FILE"
echo "Total size: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup directory: $BACKUP_DIR" >> "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"

echo "----------------------"
echo "Backup completed!"
echo "Report saved in: $REPORT_FILE"
