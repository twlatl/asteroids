require 'gosu'
require_relative 'ship'
require_relative 'asteroid'
require_relative 'bullet'
require_relative 'alien'
require_relative 'particle'
require_relative 'ship_debris'

class Game < Gosu::Window
  WIDTH = 1024
  HEIGHT = 768
  SHIP_SPAWN_X = WIDTH / 2
  SHIP_SPAWN_Y = HEIGHT / 2
  ALIEN_SPAWN_INTERVAL = 30_000 # 60 seconds in milliseconds

  @@instance = nil

  def self.instance
    @@instance
  end

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = "Asteroids"
    
    # Load custom fonts with fallback
    @font = load_custom_font(24)
    @large_font = load_custom_font(48)
    
    # Load sounds
    load_sounds
    
    @@instance = self
    
    # Game state management
    @game_state = :start_screen  # :start_screen, :playing, :game_over
    @beat_timer = 0
    @beat_interval = 500  # Start at 500ms
    @last_beat_time = 0
    
    initialize_start_screen
  end

  def load_custom_font(size)
    # Try to load the custom C&C Red Alert font
    font_path = File.join(File.dirname(__FILE__), '..', 'fonts', 'C&C Red Alert [INET].ttf')
    
    if File.exist?(font_path)
      # Use custom font
      Gosu::Font.new(size, name: font_path)
    else
      # Fallback to system font
      puts "Custom font not found at #{font_path}. Using system font."
      puts "To use the C&C Red Alert font, download it from:"
      puts "https://www.dafont.com/c-c-red-alert-inet.font"
      puts "and place 'C&C Red Alert [INET].ttf' in the fonts/ directory."
      Gosu::Font.new(size)
    end
  rescue => e
    puts "Error loading custom font: #{e.message}"
    puts "Using system font as fallback."
    Gosu::Font.new(size)
  end

  def load_sounds
    sounds_path = File.join(File.dirname(__FILE__), '..', 'sounds')
    
    @sounds = {}
    
    # Load all sound files
    sound_files = {
      fire: 'fire.wav',
      thrust: 'thrust.wav',
      bang_large: 'bangLarge.wav',
      bang_medium: 'bangMedium.wav',
      bang_small: 'bangSmall.wav',
      saucer_big: 'saucerBig.wav',
      beat1: 'beat1.wav',
      beat2: 'beat2.wav',
      level_up: 'levelUp.mp3',
    }
    
    sound_files.each do |key, filename|
      file_path = File.join(sounds_path, filename)
      if File.exist?(file_path)
        @sounds[key] = Gosu::Sample.new(file_path)
      else
        puts "Warning: Sound file not found: #{file_path}"
        @sounds[key] = nil
      end
    end
    
    # Initialize background music state
    @current_beat = nil
    @saucer_sound = nil
    @thrust_sound = nil
  rescue => e
    puts "Error loading sounds: #{e.message}"
    @sounds = {}
  end

  def initialize_start_screen
    # Create asteroids for background animation
    @asteroids = create_initial_asteroids
    @bullets = []
    @aliens = []
    @particles = []
    @ship_debris = []
    @ship = Ship.new(SHIP_SPAWN_X, SHIP_SPAWN_Y)
    @score = 0
    @lives = 3
    @level = 1
    @last_alien_spawn = 0
    @game_over = false
    @paused = false
    @respawn_timer = 0
    
    # Don't start beat sounds yet
    stop_all_sounds
  end

  def award_life
    if @score >= 5000 && @lives < 5 || @score >= 10000 && @lives < 5 || @score >= 25000 && @lives < 5
      @lives += 1
      play_sound(:level_up)
      puts "Extra life awarded! Lives: #{@lives}"
    end   
  end

  def play_sound(sound_key, volume = 1.0)
    return unless @sounds[sound_key]
    @sounds[sound_key].play(volume)
  end

  def play_looping_sound(sound_key, volume = 1.0)
    return unless @sounds[sound_key]
    @sounds[sound_key].play(volume, 1, true) # true for looping
  end

  def stop_sound(sound_instance)
    sound_instance&.stop if sound_instance.respond_to?(:stop)
  end

  def stop_all_sounds
    # Stop all looping sounds
    stop_sound(@saucer_sound)
    stop_sound(@thrust_sound)
    
    # Clear sound references
    @saucer_sound = nil
    @thrust_sound = nil
  end

  def update_background_music
    return if @paused || @game_over || @game_state != :playing
    
    current_time = Gosu.milliseconds
    
    # Calculate beat interval based on asteroid count
    initial_asteroid_count = 4 + @level
    current_asteroid_count = @asteroids.length
    
    if current_asteroid_count > 0
      # Calculate exponential rate increase as asteroids decrease
      # Start at 3 seconds (3000ms), end at 0.5 seconds (500ms)
      asteroid_ratio = current_asteroid_count.to_f / initial_asteroid_count.to_f
      
      # Exponential formula: interval decreases exponentially as ratio approaches 0
      # When ratio = 1.0 (all asteroids), interval = 1000ms
      # When ratio ≈ 0.07 (1 asteroid of 14), interval = 250ms
      min_interval = 250
      max_interval = 1000
      @beat_interval = min_interval + (max_interval - min_interval) * (asteroid_ratio ** 2)
    else
      @beat_interval = 3000  # Reset for next level
    end
    
    # Play beat if enough time has passed
    if current_time - @last_beat_time >= @beat_interval
      play_sound(:beat1, 0.25)
      @last_beat_time = current_time
    end
  end

  def reset_game
    @ship = Ship.new(SHIP_SPAWN_X, SHIP_SPAWN_Y)
    @asteroids = create_initial_asteroids
    @bullets = []
    @aliens = []
    @particles = []
    @ship_debris = []
    @score = 0
    @lives = 3
    @level = 1
    @last_alien_spawn = 0
    @game_over = false
    @paused = false
    @respawn_timer = 0
    @game_state = :playing
    
    # Reset beat timing
    @beat_interval = 3000
    @last_beat_time = Gosu.milliseconds
    
    # Stop any current sounds
    stop_all_sounds
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
    case @game_state
    when :start_screen
      update_start_screen
    when :playing
      update_playing
    when :game_over
      update_game_over
    end
  end

  def update_start_screen
    # Just animate asteroids in background
    @asteroids.each(&:update)
    @particles.each(&:update)
    @ship_debris.each(&:update)
    
    # Remove old particles and debris
    @particles.reject! { |particle| particle.should_remove? }
    @ship_debris.reject! { |debris| debris.should_remove? }
  end

  def update_playing
    update_input
    
    update_background_music
    
    return if @paused

    # Full game logic update
    update_game_logic
  end

  def update_game_over
    # Stop background music when game is over
    stop_all_sounds
    
    # Continue visual animations even when game is over
    update_animations_only
  end

  def update_animations_only
    # Continue visual updates for game over screen
    @asteroids.each(&:update)
    @aliens.each(&:update)
    @particles.each(&:update)
    @ship_debris.each(&:update)
    
    # Remove old particles and debris but keep asteroids and aliens moving
    @particles.reject! { |particle| particle.should_remove? }
    @ship_debris.reject! { |debris| debris.should_remove? }
  end

  def update_game_logic
    @ship.update unless @ship.destroyed?
    @bullets.each(&:update)
    @asteroids.each(&:update)
    @aliens.each(&:update)
    @particles.each(&:update)
    @ship_debris.each(&:update)

    # Remove old bullets, particles, and debris
    @bullets.reject! { |bullet| bullet.should_remove? }
    @particles.reject! { |particle| particle.should_remove? }
    @ship_debris.reject! { |debris| debris.should_remove? }

    # Handle ship respawn timer
    if @ship.destroyed? && @respawn_timer > 0
      @respawn_timer -= 1
      if @respawn_timer <= 0
        respawn_ship
      end
    end

    # Spawn alien ships
    spawn_alien if should_spawn_alien?

    # Handle collisions
    handle_collisions

    # Check for level completion
    next_level if @asteroids.empty?

    # Clean up dead aliens and check for aliens that have exited screen bounds
    aliens_before = @aliens.length
    
    # Check for aliens that have moved too far off screen
    @aliens.each do |alien|
      if alien.x < -200 || alien.x > WIDTH + 200 || alien.y < -200 || alien.y > HEIGHT + 200
        alien.instance_variable_set(:@destroyed, true) # Force removal
      end
    end
    
    @aliens.reject! { |alien| alien.should_remove? }
    aliens_after = @aliens.length
    
    # Stop saucer sound if all aliens are gone
    if aliens_before > 0 && aliens_after == 0
      stop_sound(@saucer_sound)
      @saucer_sound = nil
    end
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
    
    # Play saucer sound on loop
    @saucer_sound = play_looping_sound(:saucer_big, 1.0)
  end

  def handle_collisions
    # Bullet vs Asteroid collisions
    @bullets.each do |bullet|
      next if bullet.from_alien

      @asteroids.each do |asteroid|
        if collision?(bullet, asteroid)
          # Play appropriate bang sound
          case asteroid.size
          when :large
            play_sound(:bang_large)
          when :medium
            play_sound(:bang_medium)
          when :small
            play_sound(:bang_small)
          end
          
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
          # Play large bang sound for alien destruction
          play_sound(:bang_large)
          
          create_explosion_particles(alien.x, alien.y, 12)
          @score += alien.points
          # Check for extra life award after scoring
          award_life
          alien.destroy
          bullet.destroy
          break
        end
      end
    end

    # Ship vs Asteroid collisions
    @asteroids.each do |asteroid|
      if @ship.shields_active?
        # Check collision with shield radius
        distance = Math.sqrt((@ship.x - asteroid.x)**2 + (@ship.y - asteroid.y)**2)
        if distance < (@ship.shield_collision_radius + asteroid.radius)
          bounce_object_off_ship(asteroid)
        end
      elsif collision?(@ship, asteroid) && !@ship.invulnerable?
        ship_destroyed
        break
      end
    end

    # Ship vs Alien collisions
    @aliens.each do |alien|
      if @ship.shields_active?
        # Check collision with shield radius
        distance = Math.sqrt((@ship.x - alien.x)**2 + (@ship.y - alien.y)**2)
        if distance < (@ship.shield_collision_radius + alien.radius)
          bounce_object_off_ship(alien)
        end
      elsif collision?(@ship, alien) && !@ship.invulnerable?
        ship_destroyed
        break
      end
    end

    # Ship vs Alien bullet collisions
    @bullets.each do |bullet|
      next unless bullet.from_alien

      if @ship.shields_active?
        # Check collision with shield radius
        distance = Math.sqrt((@ship.x - bullet.x)**2 + (@ship.y - bullet.y)**2)
        if distance < (@ship.shield_collision_radius + bullet.radius)
          # Bounce bullet
          bounce_bullet_off_ship(bullet)
        end
      elsif collision?(@ship, bullet) && !@ship.invulnerable?
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

    # Check for extra life award after scoring
    award_life

    @asteroids.delete(asteroid)
  end

  def create_explosion_particles(x, y, count)
    count.times do
      @particles << Particle.new(x, y)
    end
  end

  def bounce_object_off_ship(object)
    # Calculate bounce direction (away from ship)
    dx = object.x - @ship.x
    dy = object.y - @ship.y
    distance = Math.sqrt(dx**2 + dy**2)
    
    return if distance == 0 # Avoid division by zero
    
    # Normalize direction
    dx /= distance
    dy /= distance
    
    # Apply bounce velocity
    bounce_force = 3.0
    if object.respond_to?(:instance_variable_get)
      current_vx = object.instance_variable_get(:@velocity_x) || 0
      current_vy = object.instance_variable_get(:@velocity_y) || 0
      
      object.instance_variable_set(:@velocity_x, current_vx + dx * bounce_force)
      object.instance_variable_set(:@velocity_y, current_vy + dy * bounce_force)
    end
    
    # Create bounce particles
    create_explosion_particles(@ship.x + dx * @ship.shield_collision_radius, 
                             @ship.y + dy * @ship.shield_collision_radius, 3)
  end

  def bounce_bullet_off_ship(bullet)
    # Calculate bounce direction (away from ship)
    dx = bullet.x - @ship.x
    dy = bullet.y - @ship.y
    distance = Math.sqrt(dx**2 + dy**2)
    
    return if distance == 0
    
    # Normalize and reverse direction
    dx /= distance
    dy /= distance
    
    # Reverse bullet direction
    current_vx = bullet.instance_variable_get(:@velocity_x)
    current_vy = bullet.instance_variable_get(:@velocity_y)
    
    bullet.instance_variable_set(:@velocity_x, dx * Math.sqrt(current_vx**2 + current_vy**2))
    bullet.instance_variable_set(:@velocity_y, dy * Math.sqrt(current_vx**2 + current_vy**2))
    bullet.instance_variable_set(:@from_alien, false) # Now it's the player's bullet
    
    # Create bounce particles
    create_explosion_particles(bullet.x, bullet.y, 2)
  end

  def ship_destroyed
    return if @ship.destroyed? # Prevent multiple destruction calls
    
    # Play ship destruction sound
    play_sound(:bang_large)
    
    create_explosion_particles(@ship.x, @ship.y, 15)
    @ship.destroy # This will create debris pieces
    @lives -= 1
    
    if @lives <= 0
      @game_state = :game_over
      @game_over = true
      # Stop all sounds when game is over
      stop_all_sounds
    else
      @respawn_timer = 180 # 3 seconds at 60 FPS
    end
  end

  def respawn_ship
    # Only respawn if there are no asteroids or aliens too close to spawn point
    safe_to_respawn = true
    
    @asteroids.each do |asteroid|
      distance = Math.sqrt((SHIP_SPAWN_X - asteroid.x)**2 + (SHIP_SPAWN_Y - asteroid.y)**2)
      if distance < 100
        safe_to_respawn = false
        break
      end
    end
    
    @aliens.each do |alien|
      distance = Math.sqrt((SHIP_SPAWN_X - alien.x)**2 + (SHIP_SPAWN_Y - alien.y)**2)
      if distance < 100
        safe_to_respawn = false
        break
      end
    end
    
    if safe_to_respawn
      @ship.respawn(SHIP_SPAWN_X, SHIP_SPAWN_Y)
    else
      @respawn_timer = 30 # Try again in half a second
    end
  end

  def next_level
    @level += 1
    @asteroids = create_initial_asteroids
    @bullets.clear
    @aliens.clear
    @particles.clear
    @ship_debris.clear
    
    # Stop saucer sound as backup when level clears
    if @saucer_sound
      stop_sound(@saucer_sound)
      @saucer_sound = nil
    end
  end

  def draw
    # Draw game objects
    case @game_state
    when :start_screen
      draw_start_screen
    when :playing
      draw_playing
    when :game_over
      draw_game_over_screen
    end
  end

  def draw_start_screen
    # Draw background asteroids
    @asteroids.each(&:draw)
    @particles.each(&:draw)
    @ship_debris.each(&:draw)
    
    # Draw "Press any key to start" message
    title_text = "ASTEROIDS"
    start_text = "Press any key to start"
    
    title_width = @large_font.text_width(title_text)
    start_width = @font.text_width(start_text)
    
    @large_font.draw_text(title_text, (WIDTH - title_width) / 2, HEIGHT / 2 - 60, 2, 1, 1, Gosu::Color::WHITE)
    @font.draw_text(start_text, (WIDTH - start_width) / 2, HEIGHT / 2 + 20, 2, 1, 1, Gosu::Color::WHITE)
  end

  def draw_playing
    # Draw game objects
    @ship.draw unless @ship.destroyed?
    @asteroids.each(&:draw)
    @bullets.each(&:draw)
    @aliens.each(&:draw)
    @particles.each(&:draw)
    @ship_debris.each(&:draw)

    # Draw UI
    draw_ui

    # Draw pause screen
    draw_pause if @paused
  end

  def draw_game_over_screen
    # Draw game objects
    @asteroids.each(&:draw)
    @bullets.each(&:draw)
    @aliens.each(&:draw)
    @particles.each(&:draw)
    @ship_debris.each(&:draw)

    # Draw UI
    draw_ui

    # Draw game over screen
    draw_game_over
  end

  def draw_ui
    @font.draw_text("Score: #{@score}", 10, 10, 1, 1, 1, Gosu::Color::WHITE)
    @font.draw_text("Lives: #{@lives}", 10, 40, 1, 1, 1, Gosu::Color::WHITE)
    @font.draw_text("Level: #{@level}", 10, 70, 1, 1, 1, Gosu::Color::WHITE)
    
    # Draw shield power bar in upper right corner
    draw_shield_power_bar
  end

  def draw_shield_power_bar
    bar_width = 100
    bar_height = 20
    bar_x = WIDTH - bar_width - 10
    bar_y = 10
    
    # Background bar
    Gosu.draw_rect(bar_x, bar_y, bar_width, bar_height, Gosu::Color::GRAY, 1)
    
    # Power level bar (monochromatic white)
    power_width = (bar_width - 4) * @ship.shield_power
    if power_width > 0
      color = Gosu::Color::WHITE
      Gosu.draw_rect(bar_x + 2, bar_y + 2, power_width, bar_height - 4, color, 1)
    end
    
    # Border
    Gosu.draw_rect(bar_x, bar_y, bar_width, 2, Gosu::Color::WHITE, 1) # Top
    Gosu.draw_rect(bar_x, bar_y + bar_height - 2, bar_width, 2, Gosu::Color::WHITE, 1) # Bottom
    Gosu.draw_rect(bar_x, bar_y, 2, bar_height, Gosu::Color::WHITE, 1) # Left
    Gosu.draw_rect(bar_x + bar_width - 2, bar_y, 2, bar_height, Gosu::Color::WHITE, 1) # Right
    
    # Label
    @font.draw_text("SHIELDS", bar_x, bar_y + bar_height + 5, 1, 1, 1, Gosu::Color::WHITE)
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
    
    text = "GAME PAUSED"
    text_width = @large_font.text_width(text)
    text_height = @large_font.height
    
    # Calculate box dimensions
    box_padding = 20
    box_width = text_width + (box_padding * 2)
    box_height = text_height + (box_padding * 2)
    box_x = (WIDTH - box_width) / 2
    box_y = (HEIGHT - box_height) / 2
    
    # Draw box background
    Gosu.draw_rect(box_x, box_y, box_width, box_height, Gosu::Color::BLACK, 2)
    
    # Draw box border
    border_width = 3
    Gosu.draw_rect(box_x, box_y, box_width, border_width, Gosu::Color::WHITE, 2) # Top
    Gosu.draw_rect(box_x, box_y + box_height - border_width, box_width, border_width, Gosu::Color::WHITE, 2) # Bottom
    Gosu.draw_rect(box_x, box_y, border_width, box_height, Gosu::Color::WHITE, 2) # Left
    Gosu.draw_rect(box_x + box_width - border_width, box_y, border_width, box_height, Gosu::Color::WHITE, 2) # Right
    
    # Draw text
    @large_font.draw_text(text, box_x + box_padding, box_y + box_padding, 2, 1, 1, Gosu::Color::WHITE)
    
    continue_text = "Press P to continue"
    continue_width = @font.text_width(continue_text)
    @font.draw_text(continue_text, (WIDTH - continue_width) / 2, box_y + box_height + 30, 2, 1, 1, Gosu::Color::WHITE)
  end

  def button_down(id)
    case @game_state
    when :start_screen
      # Any key starts the game
      reset_game
    when :playing
      case id
      when Gosu::KB_ESCAPE
        stop_all_sounds
        close
      when Gosu::KB_SPACE
        if !@paused
          if @ship.can_shoot?
            @bullets << @ship.shoot
            play_sound(:fire)
          end
        end
      when Gosu::KB_P
        @paused = !@paused
      end
    when :game_over
      case id
      when Gosu::KB_ESCAPE
        stop_all_sounds
        close
      when Gosu::KB_SPACE
        initialize_start_screen
        @game_state = :start_screen
      end
    end
  end

  def button_up(id)
    # Handle button releases if needed
  end

  # Input handling for continuous key presses
  def update_input
    return unless @game_state == :playing
    return if @game_over || @paused

    @ship.turn_left if Gosu.button_down?(Gosu::KB_LEFT)
    @ship.turn_right if Gosu.button_down?(Gosu::KB_RIGHT)
    
    # Handle thrust and thrust sound
    if Gosu.button_down?(Gosu::KB_UP)
      @ship.thrust
      # Start thrust sound if not already playing
      if @thrust_sound.nil?
        @thrust_sound = play_looping_sound(:thrust, 1.0)
      end
    else
      # Stop thrust sound when not thrusting
      if @thrust_sound
        stop_sound(@thrust_sound)
        @thrust_sound = nil
      end
    end
    
    # Shield controls
    if Gosu.button_down?(Gosu::KB_S)
      @ship.activate_shields
    else
      @ship.deactivate_shields
    end
  end

  def add_bullet(bullet)
    @bullets << bullet
  end

  def create_ship_debris(x, y, vertices, velocity_x, velocity_y)
    debris = ShipDebris.new(x, y, vertices, velocity_x, velocity_y)
    @ship_debris << debris
    debris
  end
end
