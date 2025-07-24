# Asteroids Game

A Ruby implementation of the classic Asteroids arcade game using the Gosu game library.

## Installation

1. Make sure you have Ruby installed (2.7 or later recommended)
2. Install dependencies:
   ```bash
   bundle install
   ```

## How to Play

Run the game with:
```bash
ruby main.rb
```

### Controls

- **Left Arrow**: Rotate ship left
- **Right Arrow**: Rotate ship right
- **Up Arrow**: Thrust forward
- **Spacebar**: Shoot bullets
- **Escape**: Quit game

### Gameplay

- Destroy all asteroids to advance to the next level
- Large asteroids split into 2 medium asteroids when destroyed
- Medium asteroids split into 1 small asteroid when destroyed
- Small asteroids are destroyed completely
- Objects wrap around screen edges
- Every 60 seconds, an alien ship appears and shoots at you
- Avoid collision with asteroids and alien bullets

## Game Features

- Classic vector-style graphics
- Physics-based movement with inertia
- Screen wrapping
- Progressive difficulty
- Score system
- Lives system
- Asteroid splitting mechanics
- Alien ships with AI targeting
