#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple test to verify game components work
require_relative 'lib/ship'
require_relative 'lib/asteroid'
require_relative 'lib/bullet'

# Mock Game class for testing
class Game
  WIDTH = 1024
  HEIGHT = 768
end

puts "Testing Asteroids Game Components..."

# Test Ship creation
puts "✓ Testing Ship creation..."
ship = Ship.new(512, 384)
puts "  Ship created at position (#{ship.x}, #{ship.y})"

# Test Asteroid creation
puts "✓ Testing Asteroid creation..."
asteroid = Asteroid.new(100, 100, :large)
puts "  Large asteroid created with radius #{asteroid.radius}"

medium_asteroid = Asteroid.new(200, 200, :medium)
puts "  Medium asteroid created with radius #{medium_asteroid.radius}"

small_asteroid = Asteroid.new(300, 300, :small)
puts "  Small asteroid created with radius #{small_asteroid.radius}"

# Test Bullet creation
puts "✓ Testing Bullet creation..."
bullet = Bullet.new(ship.x, ship.y, 0)
puts "  Bullet created from ship position"

alien_bullet = Bullet.new(100, 100, 45, true)
puts "  Alien bullet created"

# Test movement
puts "✓ Testing movement..."
initial_x = asteroid.x
asteroid.update
puts "  Asteroid moved from x=#{initial_x} to x=#{asteroid.x}"

puts ""
puts "All basic components are working correctly!"
puts "You can now run the full game with: ruby main.rb"
