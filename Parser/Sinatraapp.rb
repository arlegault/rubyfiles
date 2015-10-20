require 'sinatra'
require 'slim'
require "sinatra/reloader"
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'open_uri_redirections'
require 'openssl'
require 'matrix'
require 'tf-idf-similarity'
require 'narray'
$submitted_urls = []
 OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
 
get "/" do
"""
<html>
<body background= http://s8.postimg.org/50f5xmhud/seed_09.png; width:1054px; height;1054px > 

<form action='/enterinfo'>
    <input type='submit' value='                          ' style= 'background-color: Transparent; color:white; position:absolute; top:331px; left:575px; border-color:transparent; padding:10px'>

</form>
</html>
"""
end
get "/enterinfo" do
  """
  <html>
<body background= http://s18.postimg.org/h3d06jzyx/seed_10.png > 
<form action='/'>
    <input type='submit' value='     ' style= 'background-color: Transparent; color:white; position:absolute; top:2px; left:260px; border-color:transparent; padding:10px'>
</form>

<form action='/investorlist' method='get'>
 <input type = 'url' name='courl' placeholder='Enter your company url here' style = 'position:absolute; top:150px; left:390px; width:465px; height:32px; border-color:transparent'>

 <input name='coname' placeholder='Company Name' style = 'position:absolute; top:243px; left:390px; width:239px; height:34px; border-color:transparent'>

 <textarea name='codesc' placeholder='Enter a description of your company.' style = 'position:absolute; top:243px; left:651px; width:239px; height:146px; border-color:transparent'></textarea>

<select name = 'revenue' style = 'position:absolute; top:299px; left:390px; width:239px; height:34px; border-color:transparent;'>
<option name='' disabled selected style= 'display:none color:gray'>Select revenue</option>
<option>0-500k</option>
<option>500k-1M</option>
<option>1-3M</option>
<option>3-5M</option>
<option>5M+</option>
</select>

<button type='submit' style= 'background-color: Transparent; position:absolute; top:148px; left:855px; border-color:transparent; width:35px; height:36px'></button>
</form>
</body>
</html>
"""
end
get "/investorlist" do

  db=SQLite3::Database.new("companytext.db")
db.results_as_hash = true

def get_html(url) 
page = Nokogiri::HTML(open(url,:allow_redirections => :safe)) 
return page.text
end

def write_to_db(colink, name, desc)
   db=SQLite3::Database.new("companytext.db")
db.execute("INSERT INTO companies (company_name, description_text, url) VALUES (?,?, ?)", name, desc, colink)
end

def check_db_descriptions
  db=SQLite3::Database.new("companytext.db")
db_rows = db.execute("SELECT * FROM companies")

db_rows.each do |row| #iterate through db
  url = row[2]
  desc = row[1]
  company_name = row[0]
   if desc.nil? || desc.empty?
  description = get_html(url) 
  db.execute( "UPDATE companies SET description_text= :description WHERE url= :url", description, url)
  end
end
end

def calc_similarity
corpus = Array.new
  db=SQLite3::Database.new("companytext.db")
get_db_rows = db.execute("SELECT * FROM companies")
get_db_rows.each do |row| #iterate through db
  description = row[1]
  company = row[0]
  url = row[2]
  description.to_s
  doc = TfIdfSimilarity::Document.new(description) #this turns description into doc for use in simlairty
  corpus.push([company, doc])
end
store = Array.new
corpus.each do |y|
 store.push y[1]
end

model = TfIdfSimilarity::TfIdfModel.new(store, :library => :narray) #doc term matrix

matrix = model.similarity_matrix # create similarity matrix
scores = Array.new
store.each do |co|
  doctxt = co
  doc = store.last
  similarity_score = matrix[model.document_index(doctxt), model.document_index(doc)]
  scores.push ([similarity_score, doctxt])
end

scores.each do |score|
  corpus.each do |x|
    if x[1] == score[1] 
       coname = x[0] 
       sim = score[0]
  db.execute( "UPDATE companies SET similarity= :sim WHERE company_name = :coname", sim, coname) 
end
end
end
end

def verifylink(paramlink)
db=SQLite3::Database.new("companytext.db")
checklinks = db.execute("SELECT * FROM companies ")
checklinks.each do |linkss|
  if linkss[2] == paramlink
    redirect '/enterinfo' #need to add a param to this redirect that wil add an error message when the redirect happens
  end
end
end

def checkinputs(name, url, descrip)
  if name.empty? and url.empty? and descrip.empty?
    redirect '/enterinfo' #need to pass to params in this request that will show error message on form
  end
end

x = params["courl"].to_s
y = params["coname"].to_s
z = params["codesc"].to_s #need to figure out how to make form take all responses with only one submit button

checkinputs(x,y,z) #verifies form submitted is not empty
verifylink(x) #methods verifies that company url submitted in form doesnot already exist in db. redirects if so
write_to_db(x,y,z) #writes name url & description from form to db
check_db_descriptions #check db for description. if none submitted, it crawls the webpage for description text and writes it to the description column
calc_similarity #this recalcualtes similarity score for all companies in the database against the most recently added one

 db=SQLite3::Database.new("companytext.db")
 $sim_cos = db.execute("SELECT * FROM companies ORDER BY similarity DESC LIMIT 5") 
 $printcos = Array.new #these arrays grab top 5 most similar from db and save name, url and investors to the varaible sets below so they can be printed to the page
 $printinv = Array.new
 $printlinks = Array.new
$sim_cos.each do |rows|
 $printcos.push ("#{rows[0]}")
 $printinv.push ("#{rows[4]}")
 $printlinks.push ("#{rows[2]}")
end

co1 = $printcos[0]
co2 = $printcos[1]
co3 = $printcos[2] #will need to do something to handle when there are more than one company per entity
co4 = $printcos[3]
co5 = $printcos[4]

inv1 = $printinv[0] # will need to do something to handle when there are more than one investor per entity
inv2 = $printinv[1]
inv3 = $printinv[2]
inv4 = $printinv[3]
inv5 = $printinv[4]

link1 = $printlinks[0]
link2 = $printlinks[1]
link3 = $printlinks[2] #will need to handle when there are more than one company and link per entity
link4 = $printlinks[3]
link5 = $printlinks[4]

  """
<body background= http://s29.postimg.org/uw5ud8093/seed_14.png >   
<form action='/'>
    <input type='submit' value='     ' style= 'background-color: Transparent; color:white; position:absolute; top:2px; left:260px; border-color:transparent; padding:10px'>
</form>
<div style= 'color: black; font-size: 14px; position:absolute; top:244px; left:845px; background-color:white; width:115px'>#{co1}</div>
<div style= 'color: black; font-size: 14px; position:absolute; top:299px; left:845px; background-color:white; width:115px'>#{co2}</div>
<div style= 'color: black; font-size: 14px; position:absolute; top:355px; left:845px; background-color:white; width:115px'>#{co3}</div>
<div style= 'color: black; font-size: 14px; position:absolute; top:411px; left:845px; background-color:white; width:115px'>#{co4}</div>
<div style= 'color: black; font-size: 14px; position:absolute; top:467px; left:845px; background-color:white; width:115px'>#{co5}</div>

<div style= 'color: black; font-size: 12px; text-decoration: underline; position:absolute; top:260px; left:845px; background-color:white; width:115px'>#{link1}</div>
<div style= 'color: black; font-size: 12px; text-decoration: underline; position:absolute; top:315px; left:845px; background-color:white; width:115px'>#{link2}</div>
<div style= 'color: black; font-size: 12px; text-decoration: underline; position:absolute; top:371px; left:845px; background-color:white; width:115px'>#{link3}</div>
<div style= 'color: black; font-size: 12px; text-decoration: underline; position:absolute; top:427px; left:845px; background-color:white; width:115px'>#{link4}</div>
<div style= 'color: black; font-size: 12px; text-decoration: underline; position:absolute; top:483px; left:845px; background-color:white; width:115px'>#{link5}</div>

<div style= 'color: black; font-weight: bold; font-size: 12px; position:absolute; top:245px; left:341px; background-color:white; width:130px'>#{inv1}</div>
<div style= 'color: black; font-weight: bold; font-size: 12px; position:absolute; top:340px; left:341px; background-color:white; width:130px'>#{inv2}</div>
<div style= 'color: black; font-weight: bold; font-size: 12px; position:absolute; top:435px; left:341px; background-color:white; width:130px'>#{inv3}</div>
<div style= 'color: black; font-weight: bold; font-size: 12px; position:absolute; top:529px; left:341px; background-color:white; width:130px'>#{inv4}</div>
<div style= 'color: black; font-weight: bold; font-size: 12px; position:absolute; top:620px; left:341px; background-color:white; width:130px'>#{inv5}</div>
 """
end