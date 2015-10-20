require 'rubygems'
require 'nokogiri'   
require 'open-uri'
require 'openssl'
require 'mechanize'

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari' #have to specify agent alias or crunchbase blocks us
agent.ssl_version='TLSv1'

agent.follow_meta_refresh = true
agent.verify_mode= OpenSSL::SSL::VERIFY_NONE

name = "pitchbook"
page = agent.get('http://startupdelta.org/startups') #need error handling when the link is wrong
pp page
page.at("h5").each do |h5|
pp h5.text.strip
end
#page = agent.get('http://google.com/')
#pp page
#PAGE_URL = page.at("cite").text
#page = Nokogiri::HTML(open(PAGE_URL,:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
#item = page.css(".investor-link")
#item.each do |investor|
  #puts investor.text