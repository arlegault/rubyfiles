require 'rubygems'
require 'nokogiri'   
require 'open-uri'
require 'openssl'
require 'sqlite3'
require 'mechanize'

db=SQLite3::Database.new("companytext.db")
db.results_as_hash
stuff_from_db = db.execute("SELECT * FROM companies")
stuff_from_db.each do |dbrow|

  companyname = dbrow[0]
  similarity = dbrow[3]
  #needs something to normalize company names so they can be used in a url
puts companyname

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari' #have to specify agent alias or crunchbase blocks us
agent.ssl_version='TLSv1'

agent.verify_mode= OpenSSL::SSL::VERIFY_NONE
page = agent.get('https://www.crunchbase.com/', :referer => "http://www.google.com/")
puts agent.page.forms[0]

PAGE_URL = "https://www.crunchbase.com/organization/"+ companyname

#PAGE_URL = "https://www.crunchbase.com/organization/uber" #variable for URL to be parsed

page = Nokogiri::HTML(open(PAGE_URL,:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
item = page.css(".investor-link")
 puts item
item.each do |investor|
  #need to make sure this is the right format before it gets writtent to the db
inv =  investor.text
db.execute("UPDATE companies SET investors = :inv WHERE co_name = :companyname", inv, companyname)
end 
end
#commetns