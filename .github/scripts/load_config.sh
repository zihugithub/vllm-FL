#!/bin/bash
# Unit configuration loading script
# Extracts unit configuration and groups tests by task
# Usage: source load_config.sh && load_config <unit_name>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd $PROJECT_ROOT && pwd

load_config() {
    local CONFIG_FILE=".github/configs/unit.yml"
    local UNIT_NAME=$1

    if [ -z "$UNIT_NAME" ]; then
        echo "❌ Error: No unit name provided."
        return 1
    fi

    echo "Loading configuration for: $CONFIG_FILE"
    echo "Loading configuration for unit: $UNIT_NAME"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ Error: Unit configuration file not found: $CONFIG_FILE"
        return 1
    fi

    # Extract CI/CD configuration from .github/configs using yq
    echo "Extracting configuration from $CONFIG_FILE"
    DEPTH_JSON=$(/usr/local/bin/yq -r  -o=json -I=0 ".unit-conf.$UNIT_NAME.depth" "$CONFIG_FILE")
    IGNORE_JSON=$(/usr/local/bin/yq -r  -o=json -I=0 ".unit-conf.$UNIT_NAME.ignore" "$CONFIG_FILE")
    DESELECT_JSON=$(/usr/local/bin/yq -r  -o=json -I=0 ".unit-conf.$UNIT_NAME.deselect" "$CONFIG_FILE")

    echo "Depth: $DEPTH_JSON"
    echo "Ignore: $IGNORE_JSON"
    echo "Deselect: $DESELECT_JSON"

    echo "PWD: $PWD"
    # Validate required fields
    if [ -z "$DEPTH_JSON" ] || [ -z "$IGNORE_JSON" ] || [ -z "$DESELECT_JSON" ]; then
        echo "❌ Error: One or more required fields are missing in unit config '$UNIT_NAME'."
        return 1
    fi

    if [ $(echo $DEPTH_JSON | jq 'length') -gt 0 ]; then
        DEPTH=$(echo $DEPTH_JSON | jq -r '.[] | "--ignore=\(.)"' | tr '\n' ' ')
    else
        DEPTH="1"
    fi

    if [ $DEPTH_JSON = "all"];then
        DEPTH=$(find "tests" -type d | awk -F/ '{print NF-1}' | sort -nr | head -n 1)
    fi
    TEST_FLIE=$(find tests/$UNIT_NAME -mindepth 1 -maxdepth $DEPTH  -name "test_*.py" -type f)

    if [ $(echo $IGNORE_JSON | jq 'length') -gt 0 ]; then
        IGNORE=$(echo $IGNORE_JSON | jq -r '.[] | "--ignore=\(.)"' | tr '\n' ' ')
    else
        IGNORE="pass"
    fi

    if [ $(echo $DESELECT_JSON | jq 'length') -gt 0 ]; then
        DESELECT=$(echo $DESELECT_JSON | jq -r '.[] | "--ignore=\(.)"' | tr '\n' ' ')
    else
        DESELECT="pass"
    fi

    { echo 'depth<<EOFRUNSON'; echo "$DEPTH"; echo 'EOFRUNSON'; } >> $GITHUB_OUTPUT
    { echo 'ignore<<EOFRUNSON'; echo "$IGNORE"; echo 'EOFRUNSON'; } >> $GITHUB_OUTPUT
    { echo 'deselect<<EOFRUNSON'; echo "$DESELECT"; echo 'EOFRUNSON'; } >> $GITHUB_OUTPUT
}