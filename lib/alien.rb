# frozen_string_literal: true

require 'gosu'
require_relative 'bullet'

class Alien
  attr_reader :x, :y, :radius, :points

  SPEED = 2
  RADIUS = 15
  SHOOT_INTERVAL = 120 # frames between shots (2 seconds at 60 FPS)
  POINTS = 1000

  def initialize(x, y, target_ship)
    @x = x
    @y = y
    @radius = RADIUS
    @points = POINTS
    @target_ship = target_ship
    @destroyed = false
    @last_shot = 0
    @age = 0
    
    # Calculate movement direction (roughly toward center of screen)
    center_x = Game::WIDTH / 2
    center_y = Game::HEIGHT / 2
    
    dx = center_x - @x
    dy = center_y - @y
    distance = Math.sqrt(dx**2 + dy**2)
    
    @velocity_x = (dx / distance) * SPEED
    @velocity_y = (dy / distance) * SPEED
  end

  def update
    return if @destroyed
    
    # Move alien
    @x += @velocity_x
    @y += @velocity_y
    @age += 1
    
    # Shoot at player
    if @age - @last_shot > SHOOT_INTERVAL
      shoot_at_player
      @last_shot = @age
    end
    
    # Remove alien if it goes too far off screen
    if @x < -100 || @x > Game::WIDTH + 100 || @y < -100 || @y > Game::HEIGHT + 100
      @destroyed = true
    end
  end

  def should_remove?
    @destroyed
  end

  def destroy
    @destroyed = true
  end

  def draw
    return if @destroyed
    
    # Draw alien as a classic flying saucer
    color = Gosu::Color::WHITE
    
    # Top dome
    dome_points = []
    8.times do |i|
      angle = (360.0 / 8) * i
      angle_rad = Math::PI * angle / 180
      x = @x + Math.sin(angle_rad) * (@radius * 0.6)
      y = @y - @radius * 0.3 + Math.cos(angle_rad) * (@radius * 0.3)
      dome_points << [x, y]
    end
    
    # Draw dome
    dome_points.size.times do |i|
      x1, y1 = dome_points[i]
      x2, y2 = dome_points[(i + 1) % dome_points.size]
      Gosu.draw_line(x1, y1, color, x2, y2, color, 1)
    end
    
    # Bottom disc
    disc_y = @y + @radius * 0.3
    disc_points = []
    12.times do |i|
      angle = (360.0 / 12) * i
      angle_rad = Math::PI * angle / 180
      x = @x + Math.sin(angle_rad) * @radius
      y = disc_y + Math.cos(angle_rad) * (@radius * 0.2)
      disc_points << [x, y]
    end
    
    # Draw disc
    disc_points.size.times do |i|
      x1, y1 = disc_points[i]
      x2, y2 = disc_points[(i + 1) % disc_points.size]
      Gosu.draw_line(x1, y1, color, x2, y2, color, 1)
    end
    
    # Connect dome to disc
    Gosu.draw_line(@x - @radius * 0.6, @y, color, @x - @radius, disc_y, color, 1)
    Gosu.draw_line(@x + @radius * 0.6, @y, color, @x + @radius, disc_y, color, 1)
  end

  private

  def shoot_at_player
    return if @target_ship.destroyed?
    
    # Calculate angle to player
    dx = @target_ship.x - @x
    dy = @target_ship.y - @y
    
    # Add some inaccuracy
    accuracy_offset = (rand - 0.5) * 30 # +/- 15 degrees
    angle = Math.atan2(dx, -dy) * 180 / Math::PI + accuracy_offset
    
    # Create bullet
    bullet = Bullet.new(@x, @y, angle, true)
    Game.instance.add_bullet(bullet)
  end
end
