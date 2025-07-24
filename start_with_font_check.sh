#!/bin/bash

echo "=== Asteroids Game Font Setup ==="
echo ""

FONT_DIR="fonts"
FONT_FILE="C&C Red Alert [INET].ttf"
FONT_PATH="$FONT_DIR/$FONT_FILE"

# Check if fonts directory exists
if [ ! -d "$FONT_DIR" ]; then
    echo "Creating fonts directory..."
    mkdir -p "$FONT_DIR"
fi

# Check if font file exists
if [ -f "$FONT_PATH" ]; then
    echo "✓ Custom font found: $FONT_PATH"
    echo "✓ Game will use the C&C Red Alert font!"
else
    echo "⚠ Custom font not found: $FONT_PATH"
    echo ""
    echo "To install the C&C Red Alert font:"
    echo "1. Download from: https://www.dafont.com/c-c-red-alert-inet.font"
    echo "2. Extract the ZIP file"
    echo "3. Copy '$FONT_FILE' to the fonts/ directory"
    echo ""
    echo "The game will use the system font until the custom font is installed."
fi

echo ""
echo "Starting Asteroids game..."
ruby main.rb
