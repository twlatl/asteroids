# Asteroids Game Instructions

## Objective
Destroy all asteroids while avoiding collisions and enemy fire. Each level becomes progressively more difficult with more asteroids.

## Controls
- **Left Arrow Key**: Rotate ship counterclockwise
- **Right Arrow Key**: Rotate ship clockwise  
- **Up Arrow Key**: Thrust forward (accelerate)
- **Spacebar**: Fire bullets
- **S Key**: Activate shields (hold to keep active)
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

### Shield System
- **Activation**: Hold the S key to activate shields
- **Visual Effect**: A pulsating circle appears around your ship
- **Protection**: Bullets and asteroids bounce off when shields are active
- **Power Management**: Shield power drains 10% per second when active
- **Recharge**: Shield power recharges 10% every 20 seconds when inactive
- **Power Display**: Shield power bar shown in upper-right corner
- **Visual Style**: Monochromatic white bar that decreases as power drains

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
- **Shield Management**: Use shields strategically - they're powerful but limited
- **Bounce Tactics**: Bounced alien bullets become your bullets - aim them at targets!
- **Power Conservation**: Don't keep shields on constantly - manage your power wisely

## Game Over
- Game ends when you lose all lives
- Press Spacebar to restart or Escape to quit
- Try to beat your high score!
