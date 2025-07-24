# frozen_string_literal: true

require 'gosu'

class Asteroid
  attr_reader :x, :y, :radius, :size

  SIZES = {
    large: { radius: 40, speed: 2.0 },
    medium: { radius: 25, speed: 2.5 },
    small: { radius: 15, speed: 3.0 }
  }.freeze

  def initialize(x, y, size, direction = nil)
    @x = x
    @y = y
    @size = size
    @radius = SIZES[size][:radius]
    @speed = SIZES[size][:speed]
    
    # Random movement direction if not specified
    @angle = direction || rand(360)
    angle_rad = Math::PI * @angle / 180
    @velocity_x = Math.sin(angle_rad) * @speed
    @velocity_y = -Math.cos(angle_rad) * @speed
    
    # Random rotation
    @rotation = 0
    @rotation_speed = (rand - 0.5) * 3 # Random rotation between -1.5 and 1.5 degrees per frame
    
    # Generate random shape
    @vertices = generate_vertices
  end

  def update
    # Move asteroid
    @x += @velocity_x
    @y += @velocity_y
    
    # Rotate asteroid
    @rotation += @rotation_speed
    
    # Screen wrapping
    @x = (@x + Game::WIDTH) % Game::WIDTH
    @y = (@y + Game::HEIGHT) % Game::HEIGHT
  end

  def draw
    # Rotate and translate vertices
    rotated_vertices = @vertices.map do |vx, vy|
      angle_rad = Math::PI * @rotation / 180
      cos_a = Math.cos(angle_rad)
      sin_a = Math.sin(angle_rad)
      
      new_x = vx * cos_a - vy * sin_a + @x
      new_y = vx * sin_a + vy * cos_a + @y
      [new_x, new_y]
    end

    # Draw asteroid outline
    color = Gosu::Color::WHITE
    @vertices.size.times do |i|
      x1, y1 = rotated_vertices[i]
      x2, y2 = rotated_vertices[(i + 1) % @vertices.size]
      Gosu.draw_line(x1, y1, color, x2, y2, color, 1)
    end
  end

  private

  def generate_vertices
    # Generate a random asteroid shape with 8-12 vertices
    vertex_count = rand(4) + 8 # 8-11 vertices
    vertices = []
    
    vertex_count.times do |i|
      angle = (360.0 / vertex_count) * i
      # Add some randomness to the radius
      radius_variation = @radius * (0.7 + rand * 0.6) # Between 70% and 130% of base radius
      
      angle_rad = Math::PI * angle / 180
      x = Math.sin(angle_rad) * radius_variation
      y = -Math.cos(angle_rad) * radius_variation
      
      vertices << [x, y]
    end
    
    vertices
  end
end
