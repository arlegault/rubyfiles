
require 'nokogiri'   
require 'open-uri'
require 'openssl'
require 'mechanize'
require 'sqlite3'

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari' #have to specify agent alias or crunchbase blocks us
agent.ssl_version='TLSv1'

agent.follow_meta_refresh = true
agent.verify_mode= OpenSSL::SSL::VERIFY_NONE

#name = "pitchbook"

db = SQLite3::Database.new("companytext.db")
dbcall = db.execute("SELECT * FROM companies WHERE investors IS NULL OR investors = ''")
dbcall.each do |rows|
  name = rows[0]
  compurl = rows[2]
puts name
page = agent.get('https://www.google.com/search?num=100&espv=2&q=crunchbase+'+ name) #need error handling when the link is wrong

pp page.at("cite").text
#page = agent.get('http://google.com/')
#pp page
page_url = page.at("cite").text
begin
page = Nokogiri::HTML(open(page_url,:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
#page.remove_namespaces!
#checklink = page.xpath("//a[contains(@href,'http://www.pitchbook.com')]")
#checklink = page.xpath("//*[@id='info-card-overview-content']/div/dl/div[2]/dd[5]/a")

checklink = page.css("a")
hrefs = checklink.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
#pp checklink # need to figureout why i cant grab this link
pp hrefs


item = page.css(".investor-link")
item.each do |investor|
  puts investor.text
  inv = investor.text
  
db.execute("INSERT INTO investors (investor, company_name) VALUES (?,?)", inv, name)

end
rescue
  puts "could not find page"
end
end
#//.class