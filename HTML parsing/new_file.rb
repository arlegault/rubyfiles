require 'ruby gems'
require 'nokogiri'
require 'open-uri'

page = Nokogiri::HTML(open("http://pitchbook.com"))
puts page.class # => Nokogiri::HTML::Document




