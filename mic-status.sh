#!/bin/bash

# Microphone status script for Waybar
# Returns JSON format for waybar custom module

# Get the default source (microphone)
DEFAULT_SOURCE=$(pactl get-default-source 2>/dev/null)

# Check if source exists or if pactl command failed
if [ -z "$DEFAULT_SOURCE" ] || [ $? -ne 0 ]; then
    echo '{"text": "🎤", "tooltip": "No microphone found", "class": "error"}'
    exit 1
fi

# Get mute status
MUTE_STATUS=$(pactl get-source-mute "$DEFAULT_SOURCE" 2>/dev/null | awk '{print $2}')

# Check if we got mute status
if [ -z "$MUTE_STATUS" ]; then
    echo '{"text": "🎤", "tooltip": "Cannot read microphone status", "class": "error"}'
    exit 1
fi

# Get volume level
VOLUME=$(pactl get-source-volume "$DEFAULT_SOURCE" 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%')

# Default volume to 0 if we couldn't get it
if [ -z "$VOLUME" ]; then
    VOLUME=0
fi

# Determine icon and status
if [ "$MUTE_STATUS" = "yes" ]; then
    ICON="🔇"
    CLASS="muted"
    TOOLTIP="Microphone: Muted (Click to unmute)"
else
    ICON="🎤"
    CLASS="active"
    TOOLTIP="Microphone: Active ${VOLUME}% (Click to mute)"
fi

# Output JSON for waybar (escape quotes properly)
printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$ICON" "$TOOLTIP" "$CLASS"