#!/bin/bash

# CONFIG
WALLPAPER_DIR="$HOME/.config/assets/backgrounds"
STATE_FILE="/tmp/.current_wallpaper_index"
TRANSITION_ARGS="--transition-fps 120 --transition-type outer --transition-duration 0.8"
DIRECTION="$1"  # "next" or "prev"

# Debugging output
echo "WALLPAPER_DIR: $WALLPAPER_DIR"
echo "DIRECTION: $DIRECTION"
echo "STATE_FILE: $STATE_FILE"

# Read wallpapers into array
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | sort)

# Fallback if no wallpapers found
if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"  # Debugging output
    notify-send "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Load last index or start at 0
if [ -f "$STATE_FILE" ]; then
    index=$(<"$STATE_FILE")
else
    index=0
fi

# Debugging output
echo "Current wallpaper index: $index"

# Determine new index
if [[ "$DIRECTION" == "next" ]]; then
    index=$(( (index + 1) % ${#wallpapers[@]} ))
elif [[ "$DIRECTION" == "prev" ]]; then
    index=$(( (index - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))
fi

# Save the new index
echo "$index" > "$STATE_FILE"

# Debugging output
echo "New wallpaper index: $index"

# Set wallpaper
echo "Setting wallpaper: ${wallpapers[$index]}"  # Debugging output
swww img "${wallpapers[$index]}" $TRANSITION_ARGS

# Check if swww ran successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to change wallpaper"
    exit 1
fi
