# frozen_string_literal: true

require 'gosu'
require_relative 'ship'
require_relative 'asteroid'
require_relative 'bullet'
require_relative 'alien'
require_relative 'particle'

class Game < Gosu::Window
  WIDTH = 1024
  HEIGHT = 768
  SHIP_SPAWN_X = WIDTH / 2
  SHIP_SPAWN_Y = HEIGHT / 2
  ALIEN_SPAWN_INTERVAL = 60_000 # 60 seconds in milliseconds

  @@instance = nil

  def self.instance
    @@instance
  end

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = "Asteroids"
    @font = Gosu::Font.new(24)
    @large_font = Gosu::Font.new(48)
    @@instance = self
    reset_game
  end

  def reset_game
    @ship = Ship.new(SHIP_SPAWN_X, SHIP_SPAWN_Y)
    @asteroids = create_initial_asteroids
    @bullets = []
    @aliens = []
    @particles = []
    @score = 0
    @lives = 3
    @level = 1
    @last_alien_spawn = 0
    @game_over = false
    @paused = false
  end

  def create_initial_asteroids
    asteroids = []
    (4 + (@level || 1)).times do
      loop do
        x = rand(WIDTH)
        y = rand(HEIGHT)
        # Don't spawn asteroids too close to the ship
        distance = Math.sqrt((x - SHIP_SPAWN_X)**2 + (y - SHIP_SPAWN_Y)**2)
        if distance > 100
          asteroids << Asteroid.new(x, y, :large)
          break
        end
      end
    end
    asteroids
  end

  def update
    update_input
    
    return if @game_over || @paused

    @ship.update
    @bullets.each(&:update)
    @asteroids.each(&:update)
    @aliens.each(&:update)
    @particles.each(&:update)

    # Remove old bullets and particles
    @bullets.reject! { |bullet| bullet.should_remove? }
    @particles.reject! { |particle| particle.should_remove? }

    # Spawn alien ships
    spawn_alien if should_spawn_alien?

    # Handle collisions
    handle_collisions

    # Check for level completion
    next_level if @asteroids.empty?

    # Clean up dead aliens
    @aliens.reject! { |alien| alien.should_remove? }
  end

  def should_spawn_alien?
    return false if @aliens.any?
    Gosu.milliseconds - @last_alien_spawn > ALIEN_SPAWN_INTERVAL
  end

  def spawn_alien
    side = rand(4) # 0=left, 1=right, 2=top, 3=bottom
    case side
    when 0 # left
      x, y = -50, rand(HEIGHT)
    when 1 # right
      x, y = WIDTH + 50, rand(HEIGHT)
    when 2 # top
      x, y = rand(WIDTH), -50
    when 3 # bottom
      x, y = rand(WIDTH), HEIGHT + 50
    end

    @aliens << Alien.new(x, y, @ship)
    @last_alien_spawn = Gosu.milliseconds
  end

  def handle_collisions
    # Bullet vs Asteroid collisions
    @bullets.each do |bullet|
      next if bullet.from_alien

      @asteroids.each do |asteroid|
        if collision?(bullet, asteroid)
          # Create explosion particles
          create_explosion_particles(asteroid.x, asteroid.y, 8)
          
          # Handle asteroid destruction and splitting
          handle_asteroid_destruction(asteroid)
          bullet.destroy
          break
        end
      end
    end

    # Bullet vs Alien collisions
    @bullets.each do |bullet|
      next if bullet.from_alien

      @aliens.each do |alien|
        if collision?(bullet, alien)
          create_explosion_particles(alien.x, alien.y, 12)
          @score += alien.points
          alien.destroy
          bullet.destroy
          break
        end
      end
    end

    # Ship vs Asteroid collisions
    @asteroids.each do |asteroid|
      if collision?(@ship, asteroid) && !@ship.invulnerable?
        ship_destroyed
        break
      end
    end

    # Ship vs Alien collisions
    @aliens.each do |alien|
      if collision?(@ship, alien) && !@ship.invulnerable?
        ship_destroyed
        break
      end
    end

    # Ship vs Alien bullet collisions
    @bullets.each do |bullet|
      next unless bullet.from_alien

      if collision?(@ship, bullet) && !@ship.invulnerable?
        ship_destroyed
        bullet.destroy
        break
      end
    end
  end

  def collision?(obj1, obj2)
    distance = Math.sqrt((obj1.x - obj2.x)**2 + (obj1.y - obj2.y)**2)
    distance < (obj1.radius + obj2.radius)
  end

  def handle_asteroid_destruction(asteroid)
    case asteroid.size
    when :large
      @score += 20
      # Split into 2 medium asteroids
      2.times do
        angle = rand(360)
        @asteroids << Asteroid.new(asteroid.x, asteroid.y, :medium, angle)
      end
    when :medium
      @score += 50
      # Split into 1 small asteroid
      angle = rand(360)
      @asteroids << Asteroid.new(asteroid.x, asteroid.y, :small, angle)
    when :small
      @score += 100
      # Just destroyed, no split
    end

    @asteroids.delete(asteroid)
  end

  def create_explosion_particles(x, y, count)
    count.times do
      @particles << Particle.new(x, y)
    end
  end

  def ship_destroyed
    create_explosion_particles(@ship.x, @ship.y, 15)
    @lives -= 1
    
    if @lives <= 0
      @game_over = true
    else
      @ship.respawn(SHIP_SPAWN_X, SHIP_SPAWN_Y)
    end
  end

  def next_level
    @level += 1
    @asteroids = create_initial_asteroids
    @bullets.clear
    @aliens.clear
    @particles.clear
  end

  def draw
    # Draw game objects
    @ship.draw unless @ship.destroyed?
    @asteroids.each(&:draw)
    @bullets.each(&:draw)
    @aliens.each(&:draw)
    @particles.each(&:draw)

    # Draw UI
    draw_ui

    # Draw game over screen
    draw_game_over if @game_over

    # Draw pause screen
    draw_pause if @paused
  end

  def draw_ui
    @font.draw_text("Score: #{@score}", 10, 10, 1, 1, 1, Gosu::Color::WHITE)
    @font.draw_text("Lives: #{@lives}", 10, 40, 1, 1, 1, Gosu::Color::WHITE)
    @font.draw_text("Level: #{@level}", 10, 70, 1, 1, 1, Gosu::Color::WHITE)
  end

  def draw_game_over
    overlay = Gosu::Color.new(128, 0, 0, 0)
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, overlay)
    
    text = "GAME OVER"
    text_width = @large_font.text_width(text)
    @large_font.draw_text(text, (WIDTH - text_width) / 2, HEIGHT / 2 - 60, 2, 1, 1, Gosu::Color::WHITE)
    
    score_text = "Final Score: #{@score}"
    score_width = @font.text_width(score_text)
    @font.draw_text(score_text, (WIDTH - score_width) / 2, HEIGHT / 2, 2, 1, 1, Gosu::Color::WHITE)
    
    restart_text = "Press SPACE to restart or ESC to quit"
    restart_width = @font.text_width(restart_text)
    @font.draw_text(restart_text, (WIDTH - restart_width) / 2, HEIGHT / 2 + 40, 2, 1, 1, Gosu::Color::WHITE)
  end

  def draw_pause
    overlay = Gosu::Color.new(128, 0, 0, 0)
    Gosu.draw_rect(0, 0, WIDTH, HEIGHT, overlay)
    
    text = "PAUSED"
    text_width = @large_font.text_width(text)
    @large_font.draw_text(text, (WIDTH - text_width) / 2, HEIGHT / 2 - 30, 2, 1, 1, Gosu::Color::WHITE)
    
    continue_text = "Press P to continue"
    continue_width = @font.text_width(continue_text)
    @font.draw_text(continue_text, (WIDTH - continue_width) / 2, HEIGHT / 2 + 20, 2, 1, 1, Gosu::Color::WHITE)
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    when Gosu::KB_SPACE
      if @game_over
        reset_game
      elsif !@paused
        @bullets << @ship.shoot if @ship.can_shoot?
      end
    when Gosu::KB_P
      @paused = !@paused unless @game_over
    end
  end

  def button_up(id)
    # Handle button releases if needed
  end

  # Input handling for continuous key presses
  def update_input
    return if @game_over || @paused

    @ship.turn_left if Gosu.button_down?(Gosu::KB_LEFT)
    @ship.turn_right if Gosu.button_down?(Gosu::KB_RIGHT)
    @ship.thrust if Gosu.button_down?(Gosu::KB_UP)
  end

  def add_bullet(bullet)
    @bullets << bullet
  end
end
