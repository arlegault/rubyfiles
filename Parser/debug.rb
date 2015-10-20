
require 'rjb'
Point = Rjb::import('java.awt.Point')
p = Point.new(0, 0)
p.y = 80
puts "x=#{p.x}, y=#{p.y}" # => "0,80"