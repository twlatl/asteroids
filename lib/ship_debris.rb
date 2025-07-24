# frozen_string_literal: true

require 'gosu'

class ShipDebris
  attr_reader :x, :y

  LIFETIME = 120 # frames (2 seconds at 60 FPS)

  def initialize(x, y, vertices, velocity_x = 0, velocity_y = 0)
    @x = x
    @y = y
    @vertices = vertices # Array of vertex pairs that make up this piece
    @velocity_x = velocity_x + (rand - 0.5) * 4 # Add some randomness
    @velocity_y = velocity_y + (rand - 0.5) * 4
    @rotation = 0
    @rotation_speed = (rand - 0.5) * 8 # Random spin speed
    @age = 0
  end

  def update
    # Move debris
    @x += @velocity_x
    @y += @velocity_y
    
    # Rotate debris
    @rotation += @rotation_speed
    
    # Apply friction
    @velocity_x *= 0.99
    @velocity_y *= 0.99
    
    # Age the debris
    @age += 1
    
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
    
    # Rotate and translate vertices
    rotated_vertices = @vertices.map do |vx, vy|
      angle_rad = Math::PI * @rotation / 180
      cos_a = Math.cos(angle_rad)
      sin_a = Math.sin(angle_rad)
      
      new_x = vx * cos_a - vy * sin_a + @x
      new_y = vx * sin_a + vy * cos_a + @y
      [new_x, new_y]
    end

    # Draw the debris piece
    if rotated_vertices.size >= 2
      (rotated_vertices.size - 1).times do |i|
        x1, y1 = rotated_vertices[i]
        x2, y2 = rotated_vertices[i + 1]
        Gosu.draw_line(x1, y1, color, x2, y2, color, 1)
      end
    end
  end
end
