# frozen_string_literal: true

require 'gosu'

class Particle
  attr_reader :x, :y

  LIFETIME = 60 # frames (1 second at 60 FPS)
  SPEED_RANGE = (0.5..3.0)

  def initialize(x, y)
    @x = x
    @y = y
    @age = 0
    
    # Random velocity for explosion effect
    angle = rand(360)
    speed = rand(SPEED_RANGE)
    angle_rad = Math::PI * angle / 180
    
    @velocity_x = Math.sin(angle_rad) * speed
    @velocity_y = -Math.cos(angle_rad) * speed
  end

  def update
    # Move particle
    @x += @velocity_x
    @y += @velocity_y
    @age += 1
    
    # Apply friction
    @velocity_x *= 0.98
    @velocity_y *= 0.98
    
    # Screen wrapping
    @x = (@x + Game::WIDTH) % Game::WIDTH
    @y = (@y + Game::HEIGHT) % Game::HEIGHT
  end

  def should_remove?
    @age > LIFETIME
  end

  def draw
    return if should_remove?
    
    # Fade out over time
    alpha = 255 * (1.0 - @age.to_f / LIFETIME)
    color = Gosu::Color.new(alpha.to_i, 255, 255, 255)
    
    # Draw particle as a small pixel
    Gosu.draw_rect(@x.to_i, @y.to_i, 1, 1, color, 1)
  end
end
