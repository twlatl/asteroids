# Asteroids Game Instructions

## Objective
Destroy all asteroids while avoiding collisions and enemy fire. Each level becomes progressively more difficult with more asteroids.

## Controls
- **Arrow Keys**: Ship movement (left/right rotate, up thrust)
- **Spacebar**: Shoot bullets
- **S Key**: Activate shields (hold to maintain)
- **P Key**: Pause/unpause game
- **Escape**: Quit game

## Gameplay Elements

### Audio System
- **Sound Effects**: Realistic arcade-style sound effects for shooting, thrusting, and explosions
- **Background Music**: Dynamic beat music that changes based on remaining asteroids
- **Enemy Sounds**: Alien ships make a distinct sound while on screen
- **Audio Management**: All sounds automatically stop when the game ends

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
- **Extra Life**: Earn an extra life every 5000 points (up to 5 lives maximum)

### High Scores
- **Top 5 Scores**: The game tracks the top 5 highest scores
- **New High Score**: When you achieve a top 5 score, enter your 3-letter initials
- **High Score Display**: View the high score table after setting a new record
- **Persistent Storage**: High scores are saved between game sessions

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

## Game Over & High Scores
- Game ends when you lose all lives
- Asteroids and aliens continue moving in the background during game over screen
- Ship destruction animation completes fully before showing game over
- All sounds stop but visual animations continue
- **High Score Entry**: If you achieve a top 5 score, enter your initials (A-Z keys, ENTER to confirm)
- **High Score Display**: View the high score table showing rank, initials, score, and date
- Press Spacebar to restart or Escape to quit
- Try to beat your high score!
