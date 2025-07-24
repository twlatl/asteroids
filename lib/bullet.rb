# frozen_string_literal: true

require 'gosu'

class Bullet
  attr_reader :x, :y, :radius, :from_alien

  SPEED = 10
  LIFETIME = 60 # frames (1 second at 60 FPS)

  def initialize(x, y, angle, from_alien = false)
    @x = x
    @y = y
    @radius = 2
    @from_alien = from_alien
    @destroyed = false
    @age = 0
    
    # Calculate velocity based on angle
    angle_rad = Math::PI * angle / 180
    @velocity_x = Math.sin(angle_rad) * SPEED
    @velocity_y = -Math.cos(angle_rad) * SPEED
  end

  def update
    # Move bullet
    @x += @velocity_x
    @y += @velocity_y
    
    # Age bullet
    @age += 1
    
    # Screen wrapping
    @x = (@x + Game::WIDTH) % Game::WIDTH
    @y = (@y + Game::HEIGHT) % Game::HEIGHT
  end

  def should_remove?
    @destroyed || @age > LIFETIME
  end

  def destroy
    @destroyed = true
  end

  def draw
    return if @destroyed
    
    color = @from_alien ? Gosu::Color::RED : Gosu::Color::WHITE
    
    # Draw bullet as a small circle (approximated with a square)
    Gosu.draw_rect(@x - @radius, @y - @radius, @radius * 2, @radius * 2, color, 1)
  end
end
