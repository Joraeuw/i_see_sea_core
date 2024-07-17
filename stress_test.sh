#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <test_name>"
    exit 1
fi

TEST_NAME="$1"
TEST_PLAN="./stress_tests/${TEST_NAME}.jmx"
RESULTS_DIR="./stress_tests/results"
CURRENT_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="${RESULTS_DIR}/${CURRENT_TIMESTAMP}_result.jtl"
REPORT_DIR="./stress_tests/report"

if [ ! -f "$TEST_PLAN" ]; then
    echo "Test plan not found: $TEST_PLAN"
    exit 1
fi

mkdir -p "$RESULTS_DIR"

if [ -d "$REPORT_DIR" ]; then
    echo "Removing existing report directory: $REPORT_DIR"
    rm -rf "$REPORT_DIR"
fi

jmeter -n -t "$TEST_PLAN" -l "$RESULTS_FILE" -e -o "$REPORT_DIR"

echo "Test completed. Results saved to $RESULTS_FILE and report generated in $REPORT_DIR"
