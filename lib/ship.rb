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
  SHIELD_DRAIN_RATE = 1.0 / 60.0 / 10.0 # 10% per second at 60 FPS
  SHIELD_RECHARGE_RATE = 1.0 / 60.0 / 20.0 / 10.0 # 10% per 20 seconds at 60 FPS
  SHIELD_RADIUS = 24
  FLIP_SPEED = 30.0 # degrees per frame while flipping

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
    
    # Shield system
    @shields_active = false
    @shield_power = 1.0 # 100% power
    @shield_pulse_timer = 0

    # Flip state
    @flipping = false
    @flip_target_angle = 0
    @flip_direction = 1
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
    
    # Update shield system
    update_shields

    # Handle flipping rotation
    if @flipping
      diff = angle_difference(@flip_target_angle, @angle)
      if diff.abs <= FLIP_SPEED
        @angle = @flip_target_angle
        @flipping = false
      else
        @angle = normalize_angle(@angle + (FLIP_SPEED * @flip_direction))
      end
    end
  end

  def turn_left
    return if @flipping
    @angle -= ROTATION_SPEED
  end

  def turn_right
    return if @flipping
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

  def activate_shields
    if @shield_power > 0 && !@destroyed
      @shields_active = true
    end
  end

  def deactivate_shields
    @shields_active = false
  end

  def shields_active?
    @shields_active && @shield_power > 0
  end

  def shield_power
    @shield_power
  end

  def update_shields
    @shield_pulse_timer += 1
    
    if @shields_active
      # Drain shield power when active
      @shield_power -= SHIELD_DRAIN_RATE
      
      # Disable shields when power is depleted
      if @shield_power <= 0
        @shield_power = 0
        @shields_active = false
      end
    else
      # Recharge shields when not active
      if @shield_power < 1.0
        @shield_power += SHIELD_RECHARGE_RATE
        @shield_power = [@shield_power, 1.0].min
      end
    end
  end

  def shield_collision_radius
    SHIELD_RADIUS
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
    @shields_active = false
    @shield_power = 1.0 # Full power on respawn
    @shield_pulse_timer = 0
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

    # Draw shields first (behind ship)
    draw_shields if shields_active?

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

  def draw_shields
    # Calculate pulsating effect
    pulse_factor = (Math.sin(@shield_pulse_timer * 0.2) + 1) * 0.5 # 0 to 1
    shield_alpha = (100 + pulse_factor * 100).to_i # 100 to 200 alpha
    
    # Shield color based on power level
    if @shield_power > 0.6
      color = Gosu::Color.new(shield_alpha, 0, 150, 255) # Blue
    elsif @shield_power > 0.3
      color = Gosu::Color.new(shield_alpha, 255, 255, 0) # Yellow
    else
      color = Gosu::Color.new(shield_alpha, 255, 100, 0) # Orange/Red
    end
    
    # Draw shield circle using lines (approximated circle)
    segments = 24
    (0...segments).each do |i|
      angle1 = (2 * Math::PI * i) / segments
      angle2 = (2 * Math::PI * (i + 1)) / segments
      
      x1 = @x + Math.cos(angle1) * SHIELD_RADIUS
      y1 = @y + Math.sin(angle1) * SHIELD_RADIUS
      x2 = @x + Math.cos(angle2) * SHIELD_RADIUS
      y2 = @y + Math.sin(angle2) * SHIELD_RADIUS
      
      Gosu.draw_line(x1, y1, color, x2, y2, color, 1)
    end
  end

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

  def start_flip
    return if @destroyed || @flipping
    @flip_target_angle = normalize_angle(@angle + 180)
    diff = angle_difference(@flip_target_angle, @angle)
    @flip_direction = diff >= 0 ? 1 : -1
    @flipping = true
  end

  public :start_flip

  def normalize_angle(a)
    a % 360
  end

  def angle_difference(target, current)
    diff = normalize_angle(target - current)
    diff -= 360 if diff > 180
    diff
  end
end
