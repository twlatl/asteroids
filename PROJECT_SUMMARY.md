# Asteroids Ga├── fonts/                # Custom font files (C&C Red Alert style)
├── lib/
    ├── game.rb           # Main game class and loop
    ├── ship.rb           # Player spaceship
    ├── asteroid.rb       # Asteroid objects (large, medium, small)
    ├── bullet.rb         # Bullet projectiles
    ├── alien.rb          # Enemy alien ships
    ├── particle.rb       # Explosion particle effects
    └── ship_debris.rb    # Ship destruction debris piecesoject Summary

## Overview
A complete implementation of the classic Asteroids arcade game in Ruby using the Gosu graphics library. This faithful recreation includes all the core gameplay mechanics from the original 1979 Atari game.

## Project Structure
```
asteroids/
├── Gemfile                 # Ruby dependencies
├── README.md              # Project documentation
├── INSTRUCTIONS.md        # Game instructions and controls
├── main.rb               # Game entry point
├── start_game.sh         # Shell script to launch game
├── test_components.rb    # Basic component testing
├── fonts/                # Custom font files (C&C Red Alert style)
├── sounds/               # Audio files for sound effects and music
└── lib/
    ├── game.rb           # Main game class and loop
    ├── ship.rb           # Player spaceship
    ├── asteroid.rb       # Asteroid objects (large, medium, small)
    ├── bullet.rb         # Bullet projectiles
    ├── alien.rb          # Enemy alien ships
    ├── particle.rb       # Explosion particle effects
    └── ship_debris.rb    # Ship destruction debris pieces
```

## Features Implemented

### Core Gameplay
- ✅ Spaceship with realistic physics (momentum, thrust, rotation)
- ✅ Asteroid field with 3 sizes (large → 2 medium → 1 small)
- ✅ Screen wrapping for all objects
- ✅ Collision detection
- ✅ Shooting mechanics
- ✅ Lives system (3 lives)
- ✅ Score system
- ✅ Level progression

### Advanced Features
- ✅ Alien ships that appear every 60 seconds
- ✅ AI targeting for alien ships
- ✅ Particle explosion effects
- ✅ Ship destruction animation with spinning debris pieces
- ✅ Shield system with power management
- ✅ Shield visual effects (pulsating circle)
- ✅ Bullet/asteroid bouncing off shields
- ✅ Shield power bar display
- ✅ Safe respawn system (won't respawn near hazards)
- ✅ Invulnerability period after ship destruction
- ✅ Pause functionality with visual overlay
- ✅ Game over and restart mechanics
- ✅ Animated game over screen (asteroids continue moving)
- ✅ Vector-style graphics rendering
- ✅ Custom retro font system (C&C Red Alert style)
- ✅ Font fallback system for compatibility
- ✅ Random asteroid shapes and movement
- ✅ Complete audio system with sound effects and music

### Controls
- **Arrow Keys**: Ship movement (left/right rotate, up thrust)
- **Spacebar**: Shoot bullets
- **S Key**: Activate shields (hold to maintain)
- **P Key**: Pause/unpause game
- **Escape**: Quit game

### Audio System
- **Fire Sound**: Plays when ship shoots
- **Thrust Sound**: Loops while thrusting
- **Explosion Sounds**: Different sounds for large/medium/small asteroid destruction
- **Enemy Ship Sound**: Loops while alien ship is on screen
- **Background Music**: Beat1 plays normally, switches to Beat2 when <30% asteroids remain
- **Ship Destruction**: Explosion sound when player ship is destroyed

### Visual Effects
- Vector-style line graphics (authentic to original)
- Thrust flame animation
- Explosion particle effects
- Ship invulnerability blinking
- Screen wrapping for seamless movement

## Technical Implementation

### Game Engine
- Built with **Gosu** graphics library
- 60 FPS game loop
- Object-oriented design with separate classes for each game entity
- Physics simulation with velocity, momentum, and friction
- Efficient collision detection using distance calculations

### Game Mechanics
- **Asteroid Splitting**: Large → 2 Medium → 1 Small → Destroyed
- **Screen Wrapping**: All objects wrap around screen edges
- **Alien AI**: Appears every 60 seconds, shoots at player with slight inaccuracy
- **Scoring**: 20/50/100 points for large/medium/small asteroids, 1000 for aliens
- **Extra Lives**: Award extra life every 5000 points (maximum 5 lives)
- **Progressive Difficulty**: More asteroids each level

## How to Run

### Prerequisites
- Ruby 2.7+ installed
- Bundler gem

### Installation & Launch
```bash
# Install dependencies
bundle install

# Run the game
ruby main.rb

# Or use the launch script
./start_game.sh
```

### Testing
```bash
# Test basic components
ruby test_components.rb
```

## Code Quality
- Well-structured object-oriented design
- Separated concerns (each class handles one type of game object)
- Clear method names and documentation
- Error handling and edge cases covered
- Modular design for easy expansion

This implementation provides a complete, playable Asteroids game that faithfully recreates the original gameplay experience with modern Ruby code practices.
