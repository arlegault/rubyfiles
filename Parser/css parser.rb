require 'rubygems'
require 'nokogiri'   
require 'open-uri'
# have to require the above for this to work

PAGE_URL = "http://feeds.feedburner.com/TechCrunch/" #variable for URL to be parsed


page = Nokogiri::HTML(open(PAGE_URL))
item = page.css("item")
#links and titles reside within the item tags this grabs all the attributes and puts them in an array

puts item.length   
puts item[0]["link"].text  
puts item[0]["title"].text
puts item[0]
# first series of puts. should put the length of the array, the link and the title of the link

i = 0

#while i < links.length do
 # puts links[i].text
  #puts links[i]["href"]
  #i += 1
#end

#a small script to iterate over the array. Should print the title and URL of each link