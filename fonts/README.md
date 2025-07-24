# Font Installation Instructions

## C&C Red Alert Font

To use the custom C&C Red Alert font in the Asteroids game:

1. **Download the font**:
   - Go to: https://www.dafont.com/c-c-red-alert-inet.font
   - Click "Download" to get the ZIP file
   - Extract the ZIP file

2. **Install the font files**:
   - Copy both font files to the `fonts/` directory:
     - `C&C Red Alert [INET].ttf`
     - `C&C Red Alert [LAN].ttf`

3. **Recommended font file**:
   - Use `C&C Red Alert [INET].ttf` (the Internet version)
   - This is the cleaner version of the two fonts

4. **Font size**:
   - The font looks best at 10pt size (as recommended by the creator)
   - The game will automatically scale appropriately

## Directory Structure
```
asteroids/
├── fonts/
│   ├── C&C Red Alert [INET].ttf  ← Place downloaded font here
│   └── C&C Red Alert [LAN].ttf   ← Optional: second font variant
└── lib/
    └── game.rb                   ← Updated to use custom font
```

## Note
The font is 100% free for both personal and commercial use.
Original size used in C&C Red Alert game was 10pt.
