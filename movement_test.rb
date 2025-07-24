#!/usr/bin/env ruby
require_relative 'lib/game'
require_relative 'lib/asteroid'
require_relative 'lib/ship'

puts "=== MOVEMENT TEST ==="
puts "\n1. Testing Asteroid Movement (should be visible):"
asteroid = Asteroid.new(100, 100, :large)
puts "Initial: x=#{asteroid.x.round(1)}, y=#{asteroid.y.round(1)}"
puts "Speed: #{asteroid.instance_variable_get(:@speed)}"
puts "Velocity: x=#{asteroid.instance_variable_get(:@velocity_x).round(2)}, y=#{asteroid.instance_variable_get(:@velocity_y).round(2)}"

puts "\nMovement over 10 frames:"
10.times do |i|
  old_x, old_y = asteroid.x, asteroid.y
  asteroid.update
  dx = asteroid.x - old_x
  dy = asteroid.y - old_y
  puts "Frame #{i+1}: x=#{asteroid.x.round(1)}, y=#{asteroid.y.round(1)} (moved #{dx.round(2)}, #{dy.round(2)})"
end

puts "\n2. Testing Ship Thrust (should move when UP pressed):"
ship = Ship.new(500, 400)
puts "Initial: x=#{ship.x}, y=#{ship.y}"
puts "Initial velocity: x=#{ship.instance_variable_get(:@velocity_x)}, y=#{ship.instance_variable_get(:@velocity_y)}"

puts "\nSimulating UP key press (thrust):"
ship.thrust
puts "After thrust: velocity x=#{ship.instance_variable_get(:@velocity_x).round(3)}, y=#{ship.instance_variable_get(:@velocity_y).round(3)}"

puts "\nPosition after 5 updates with thrust:"
5.times do |i|
  old_x, old_y = ship.x, ship.y
  ship.update
  dx = ship.x - old_x  
  dy = ship.y - old_y
  puts "Frame #{i+1}: x=#{ship.x.round(2)}, y=#{ship.y.round(2)} (moved #{dx.round(3)}, #{dy.round(3)})"
end

puts "\n=== TEST COMPLETE ==="
