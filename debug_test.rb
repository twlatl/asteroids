#!/usr/bin/env ruby
require_relative 'lib/game'
require_relative 'lib/asteroid'
require_relative 'lib/ship'

puts "Testing Asteroid Movement:"
asteroid = Asteroid.new(100, 100, :large)
puts "Initial position: x=#{asteroid.x}, y=#{asteroid.y}"
puts "Velocity: x=#{asteroid.instance_variable_get(:@velocity_x)}, y=#{asteroid.instance_variable_get(:@velocity_y)}"

5.times do |i|
  asteroid.update
  puts "Frame #{i+1}: x=#{asteroid.x.round(2)}, y=#{asteroid.y.round(2)}"
end

puts "\nTesting Ship Thrust:"
ship = Ship.new(500, 400)
puts "Initial position: x=#{ship.x}, y=#{ship.y}"
puts "Initial velocity: x=#{ship.instance_variable_get(:@velocity_x)}, y=#{ship.instance_variable_get(:@velocity_y)}"

ship.thrust
puts "After thrust - velocity: x=#{ship.instance_variable_get(:@velocity_x)}, y=#{ship.instance_variable_get(:@velocity_y)}"

ship.update
puts "After update - position: x=#{ship.x}, y=#{ship.y}"
