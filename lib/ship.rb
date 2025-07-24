# frozen_string_literal: true

require 'gosu'
require_relative 'bullet'
require_relative 'ship_debris'

class Ship
  attr_reader :x, :y, :radius

  THRUST_POWER = 0.5
  ROTATION_SPEED = 4.5
  MAX_SPEED = 8
  FRICTION = 0.98
  INVULNERABILITY_TIME = 3000 # 3 seconds in milliseconds

  def initialize(x, y)
    @x = x
    @y = y
    @angle = 0
    @velocity_x = 0
    @velocity_y = 0
    @radius = 16
    @last_shot = 0
    @shot_cooldown = 150 # milliseconds between shots
    @invulnerable_until = 0
    @destroyed = false
    @debris_created = false
  end

  def update
    # Apply velocity
    @x += @velocity_x
    @y += @velocity_y

    # Apply friction
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION

    # Screen wrapping
    @x = (@x + Game::WIDTH) % Game::WIDTH
    @y = (@y + Game::HEIGHT) % Game::HEIGHT
  end

  def turn_left
    @angle -= ROTATION_SPEED
  end

  def turn_right
    @angle += ROTATION_SPEED
  end

  def thrust
    # Convert angle to radians and calculate thrust vector
    angle_rad = Math::PI * @angle / 180
    thrust_x = Math.sin(angle_rad) * THRUST_POWER
    thrust_y = -Math.cos(angle_rad) * THRUST_POWER

    # Apply thrust
    @velocity_x += thrust_x
    @velocity_y += thrust_y

    # Limit maximum speed
    speed = Math.sqrt(@velocity_x**2 + @velocity_y**2)
    if speed > MAX_SPEED
      @velocity_x = (@velocity_x / speed) * MAX_SPEED
      @velocity_y = (@velocity_y / speed) * MAX_SPEED
    end
  end

  def can_shoot?
    Gosu.milliseconds - @last_shot > @shot_cooldown
  end

  def shoot
    return nil unless can_shoot?

    @last_shot = Gosu.milliseconds
    
    # Calculate bullet spawn position (at tip of ship)
    angle_rad = Math::PI * @angle / 180
    spawn_x = @x + Math.sin(angle_rad) * @radius
    spawn_y = @y - Math.cos(angle_rad) * @radius

    Bullet.new(spawn_x, spawn_y, @angle, false)
  end

  def invulnerable?
    Gosu.milliseconds < @invulnerable_until
  end

  def respawn(x, y)
    @x = x
    @y = y
    @velocity_x = 0
    @velocity_y = 0
    @angle = 0
    @invulnerable_until = Gosu.milliseconds + INVULNERABILITY_TIME
    @destroyed = false
    @debris_created = false
  end

  def destroyed?
    @destroyed
  end

  def destroy
    @destroyed = true
    create_debris
  end

  def create_debris
    return if @debris_created # Prevent creating debris multiple times
    @debris_created = true
    
    # Get the current ship vertices
    vertices = [
      [0, -@radius],           # tip
      [-@radius/2, @radius/2], # bottom left
      [@radius/2, @radius/2]   # bottom right
    ]

    # Rotate vertices to current ship orientation
    rotated_vertices = vertices.map do |vx, vy|
      angle_rad = Math::PI * @angle / 180
      cos_a = Math.cos(angle_rad)
      sin_a = Math.sin(angle_rad)
      
      new_x = vx * cos_a - vy * sin_a + @x
      new_y = vx * sin_a + vy * cos_a + @y
      [new_x, new_y]
    end

    # Create debris pieces - each side of the triangle becomes a piece
    debris_pieces = []
    
    # Piece 1: Left side (tip to bottom left)
    piece1_vertices = [
      [rotated_vertices[0][0] - @x, rotated_vertices[0][1] - @y], # tip (relative to center)
      [rotated_vertices[1][0] - @x, rotated_vertices[1][1] - @y]  # bottom left
    ]
    debris_pieces << Game.instance.create_ship_debris(@x, @y, piece1_vertices, @velocity_x, @velocity_y)
    
    # Piece 2: Right side (tip to bottom right)
    piece2_vertices = [
      [rotated_vertices[0][0] - @x, rotated_vertices[0][1] - @y], # tip (relative to center)
      [rotated_vertices[2][0] - @x, rotated_vertices[2][1] - @y]  # bottom right
    ]
    debris_pieces << Game.instance.create_ship_debris(@x, @y, piece2_vertices, @velocity_x, @velocity_y)
    
    # Piece 3: Bottom side (bottom left to bottom right)
    piece3_vertices = [
      [rotated_vertices[1][0] - @x, rotated_vertices[1][1] - @y], # bottom left (relative to center)
      [rotated_vertices[2][0] - @x, rotated_vertices[2][1] - @y]  # bottom right
    ]
    debris_pieces << Game.instance.create_ship_debris(@x, @y, piece3_vertices, @velocity_x, @velocity_y)
  end

  def draw
    return if @destroyed

    # Flicker when invulnerable
    if invulnerable? && (Gosu.milliseconds / 100) % 2 == 0
      return
    end

    # Ship vertices (triangle pointing up)
    vertices = [
      [0, -@radius],      # tip
      [-@radius/2, @radius/2],  # bottom left
      [@radius/2, @radius/2]    # bottom right
    ]

    # Rotate and translate vertices
    rotated_vertices = vertices.map do |vx, vy|
      angle_rad = Math::PI * @angle / 180
      cos_a = Math.cos(angle_rad)
      sin_a = Math.sin(angle_rad)
      
      new_x = vx * cos_a - vy * sin_a + @x
      new_y = vx * sin_a + vy * cos_a + @y
      [new_x, new_y]
    end

    # Draw ship outline
    color = Gosu::Color::WHITE
    3.times do |i|
      x1, y1 = rotated_vertices[i]
      x2, y2 = rotated_vertices[(i + 1) % 3]
      Gosu.draw_line(x1, y1, color, x2, y2, color, 1)
    end

    # Draw thrust flame when thrusting
    if Gosu.button_down?(Gosu::KB_UP)
      draw_thrust_flame(rotated_vertices)
    end
  end

  private

  def draw_thrust_flame(vertices)
    # Draw flame from back of ship
    back_center_x = (vertices[1][0] + vertices[2][0]) / 2
    back_center_y = (vertices[1][1] + vertices[2][1]) / 2
    
    # Flame tip position
    angle_rad = Math::PI * @angle / 180
    flame_length = @radius + rand(5) # Random flame length for flicker effect
    flame_x = back_center_x - Math.sin(angle_rad) * flame_length
    flame_y = back_center_y + Math.cos(angle_rad) * flame_length

    # Draw flame
    color = Gosu::Color.new(255, 255, rand(100) + 155, 0) # Yellow to orange
    Gosu.draw_line(vertices[1][0], vertices[1][1], color, flame_x, flame_y, color, 1)
    Gosu.draw_line(vertices[2][0], vertices[2][1], color, flame_x, flame_y, color, 1)
  end
end
