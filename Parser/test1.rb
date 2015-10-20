require 'nokogiri'
require 'sqlite3'
db = SQLite3::Database.new("patents.db")
array = db.execute("SELECT application_number FROM patent_listing")
array.each do |x|
app_number = x[0]
puts app_number.inspect

 if db.execute("SELECT 1 FROM patent_listing WHERE application_number = :app_number LIMIT 1", app_number)
  puts "match"
 else
   puts "no match"
end
  end