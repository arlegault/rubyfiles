require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'open_uri_redirections'
require 'openssl'

db=SQLite3::Database.new("companytext.db")
db.results_as_hash = true

def get_html(url) 
  
page = Nokogiri::HTML(open(url,:allow_redirections => :safe)) 
return page.text
end

db_rows = db.execute("SELECT company_name FROM companies")

db_rows.each do |row| #iterate through db
  url = row[2]
  desc = row[1]
  company_name = row[0]
   if desc.nil? || desc.empty?
  description = get_html(url) 
  puts description
  db.execute( "UPDATE companies SET description_text= :description WHERE url= :url", description, url)
  else
    puts "description text already exists"
  end
end
def get_most_similar
 db=SQLite3::Database.new("companytext.db")
 sim_cos = db.execute("SELECT * FROM companies ORDER BY similarity DESC LIMIT 5") 
sim_cos.each do |rows|
 puts rows[0]
end
end
get_most_similar

#<em style='color: black; font-size: 10px; position:absolute; top:400px; left:855px; background-color:white;'> #{ co2 } </em>

 # this get method would then be called at a defined interval, either batches or time, to crawl a list of urls dumped into it.
 
