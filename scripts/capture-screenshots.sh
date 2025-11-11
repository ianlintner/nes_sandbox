#!/bin/bash
# Script to capture screenshots from NES ROM using FCEUX emulator
# This script uses FCEUX's built-in screenshot feature (F12 key)

set -e

# Configuration
ROM_FILE="${1:-catmecha.nes}"
SCREENSHOT_DIR="${2:-screenshots}"
DURATION="${3:-30}"  # Duration in seconds

# Check if ROM file exists
if [ ! -f "$ROM_FILE" ]; then
    echo "Error: ROM file not found: $ROM_FILE"
    echo "Usage: $0 [rom_file] [screenshot_dir] [duration_seconds]"
    exit 1
fi

# Create screenshot directory
mkdir -p "$SCREENSHOT_DIR"

# Clean up FCEUX snaps directory
rm -rf ~/.fceux/snaps/*

echo "=== NES Screenshot Capture ==="
echo "ROM: $ROM_FILE"
echo "Output Directory: $SCREENSHOT_DIR"
echo "Duration: ${DURATION}s"
echo ""

# Start Xvfb on a specific display
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!
echo "Started Xvfb (PID: $XVFB_PID)"
sleep 2

# Start FCEUX in the background
echo "Starting FCEUX..."
fceux --sound 0 "$ROM_FILE" > /dev/null 2>&1 &
FCEUX_PID=$!
echo "Started FCEUX (PID: $FCEUX_PID)"
sleep 4

# Capture screenshots at specific intervals using F12 key
echo "Capturing screenshots..."
INTERVALS=(1 3 6 10 15 20 25 30)
for i in "${!INTERVALS[@]}"; do
    DELAY="${INTERVALS[$i]}"
    if [ $DELAY -le $DURATION ]; then
        # Calculate sleep time from previous interval
        PREV_DELAY=${INTERVALS[$((i-1))]:-0}
        SLEEP_TIME=$((DELAY - PREV_DELAY))
        
        if [ $SLEEP_TIME -gt 0 ]; then
            sleep $SLEEP_TIME
        fi
        
        # Send F12 key to capture screenshot in FCEUX
        xdotool key F12 2>/dev/null || echo "  Warning: xdotool failed"
        sleep 0.5
        
        echo "  [${DELAY}s] Triggered screenshot $(printf %02d $((i+1)))"
    fi
done

# Give FCEUX a moment to save final screenshots
sleep 1

# Cleanup
echo ""
echo "Cleaning up..."
kill $FCEUX_PID 2>/dev/null || true
wait $FCEUX_PID 2>/dev/null || true
kill $XVFB_PID 2>/dev/null || true
wait $XVFB_PID 2>/dev/null || true

# Copy screenshots from FCEUX snaps directory
echo "Collecting screenshots from FCEUX..."
SNAP_COUNT=0
if [ -d ~/.fceux/snaps/ ]; then
    for snap in ~/.fceux/snaps/*.png; do
        if [ -f "$snap" ]; then
            SNAP_COUNT=$((SNAP_COUNT + 1))
            BASENAME=$(basename "$snap")
            cp "$snap" "$SCREENSHOT_DIR/gameplay_$(printf %02d $SNAP_COUNT)_${BASENAME}"
            echo "  Copied: $(basename "$snap")"
        fi
    done
fi

# Check if screenshots were created
SCREENSHOT_COUNT=$(find "$SCREENSHOT_DIR" -name "*.png" -size +1000c 2>/dev/null | wc -l)
echo ""
echo "=== Capture Complete ==="
echo "Screenshots created: $SCREENSHOT_COUNT"

if [ $SCREENSHOT_COUNT -eq 0 ]; then
    echo "Warning: No valid screenshots were created!"
    echo "Checking for any files in snaps directory:"
    ls -lh ~/.fceux/snaps/ 2>/dev/null || echo "  (directory empty or doesn't exist)"
    exit 1
fi

echo ""
echo "Screenshots saved to: $SCREENSHOT_DIR/"
ls -lh "$SCREENSHOT_DIR"/*.png 2>/dev/null || true

exit 0
