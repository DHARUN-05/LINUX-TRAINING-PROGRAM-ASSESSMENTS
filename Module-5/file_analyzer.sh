#!/bin/bash

ERROR_LOG="errors.log"

# Redirect errors to log and terminal
exec 2> >(tee -a "$ERROR_LOG")

# --- Help Menu (Here Document) ---
show_help() {
cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>   Directory to search recursively
  -f <file>        File to search directly
  -k <keyword>     Keyword to search
  --help           Display this help

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}

# --- Recursive Function ----
search_recursive() {
    local dir="$1"
    local key="$2"

    for item in "$dir"/*
    do
        if [ -f "$item" ]; then
            grep -H "$key" "$item" 2>/dev/null
        elif [ -d "$item" ]; then
            search_recursive "$item" "$key"
        fi
    done
}

# Regex
validate_inputs() {

    # Check keyword (not empty, only letters/numbers)
    if [[ ! "$KEYWORD" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Invalid keyword format" >&2
        exit 1
    fi

    # Check file
    if [ -n "$FILE" ] && [ ! -f "$FILE" ]; then
        echo "File does not exist: $FILE" >&2
        exit 1
    fi

    # Check directory
    if [ -n "$DIR" ] && [ ! -d "$DIR" ]; then
        echo "Directory does not exist: $DIR" >&2
        exit 1
    fi
}

# --- Here String Search ---
search_here_string() {
    grep "$KEYWORD" <<< "$1"
}

# Argument Count Info
echo "Script Name: $0"
echo "Total Arguments: $#"
echo "All Arguments: $@"

# --- Parse Arguments ---
DIR=""
FILE=""
KEYWORD=""

while getopts ":d:f:k:-:" opt
do
    case $opt in
        d) DIR="$OPTARG" ;;
        f) FILE="$OPTARG" ;;
        k) KEYWORD="$OPTARG" ;;
        -)
            case $OPTARG in
                help)
                    show_help
                    exit 0
                    ;;
            esac ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1 ;;
    esac
done

# --- Check Required Keyword ---
if [ -z "$KEYWORD" ]; then
    echo "Keyword is required (-k)" >&2
    exit 1
fi

# --- Validate ---
validate_inputs

#-- Perform Search --
echo "Searching for: $KEYWORD"
echo "-----------------------"

if [ -n "$FILE" ]; then

    echo "Searching in file: $FILE"

    # Here String
    content=$(cat "$FILE")
    search_here_string "$content"

elif [ -n "$DIR" ]; then

    echo "Searching in directory: $DIR"
    search_recursive "$DIR" "$KEYWORD"

else
    echo "Either -d or -f must be provided" >&2
    exit 1
fi

# Exit Status 
echo "Exit Status: $?"
