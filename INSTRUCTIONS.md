# Asteroids Game Instructions

## Objective
Destroy all asteroids while avoiding collisions and enemy fire. Each level becomes progressively more difficult with more asteroids.

## Controls
- **Left Arrow Key**: Rotate ship counterclockwise
- **Right Arrow Key**: Rotate ship clockwise  
- **Up Arrow Key**: Thrust forward (accelerate)
- **Spacebar**: Fire bullets
- **P**: Pause/unpause game
- **Escape**: Quit game

## Gameplay Elements

### Ship
- Your triangular spaceship starts in the center of the screen
- The ship maintains momentum when you stop thrusting (realistic physics)
- When destroyed by collision, the ship breaks apart into spinning debris pieces
- After destruction, you respawn after 3 seconds with temporary invulnerability
- The ship won't respawn if asteroids or aliens are too close to the spawn point
- You start with 3 lives

### Asteroids
- **Large Asteroids**: Split into 2 medium asteroids when destroyed (20 points)
- **Medium Asteroids**: Split into 1 small asteroid when destroyed (50 points)
- **Small Asteroids**: Completely destroyed (100 points)
- All asteroids rotate and move in straight lines
- Asteroids have randomized shapes for variety

### Alien Ships
- Appear every 60 seconds
- Move across the screen while shooting at your ship
- Worth 1000 points when destroyed
- Their bullets are red (yours are white)
- Will disappear if they travel off-screen

### Screen Wrapping
- All objects (ship, asteroids, bullets, aliens) wrap around screen edges
- If something goes off the top, it appears at the bottom, etc.

### Scoring
- Large asteroid: 20 points
- Medium asteroid: 50 points  
- Small asteroid: 100 points
- Alien ship: 1000 points

### Level Progression
- Clear all asteroids to advance to the next level
- Each level starts with more asteroids
- Level number is displayed in the top-left corner

## Strategy Tips
- Use the ship's momentum to your advantage for efficient movement
- Clear smaller asteroids first as they move faster and are worth more points
- Be careful when shooting large asteroids near your ship
- Use screen wrapping to escape dangerous situations
- Take advantage of invulnerability time after respawning

## Game Over
- Game ends when you lose all lives
- Press Spacebar to restart or Escape to quit
- Try to beat your high score!
