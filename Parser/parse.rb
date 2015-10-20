require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'mechanize'
require 'net/http'
require 'restclient'

# this is defining a sqlite db on my local machine. reassign this variable to us a different db
$db = SQLite3::Database.new("patents.db")

#urls to get contruct patent numbers and searches
$base_url = "http://patft.uspto.gov"
$search_entry_page = "http://patft.uspto.gov/netahtml/PTO/search-bool.html" #search entry page


#a method that grabs entities from a db and feeds them to the search url constructor. This will need to be modified to work with pb's db
def get_patents_today
  entities = $db.execute("SELECT formal_name, entityid FROM entities")
  entities.each do |x|
    get_search_url(x[0], x[1])
  end
end

#a method to construct the search url
def get_search_url(name, id)

  #erplace spaces with plus signs
  modified_name = name.strip.gsub(/\s/, "+")

  #increment the page starting at 2
  page_number = 2

  #construct full search url
   initial_search = $base_url + "/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-bool.html&r=0&f=S&l=50&TERM1=" + modified_name+"&FIELD1=ASNM&co1=AND&TERM2=&FIELD2=&d=PTXT"

   #grabs all links on the search result page
    get_html(initial_search, id)
   page = Nokogiri::HTML(open(initial_search))
  total_search_results = page.css("strong")[2].text.to_i #double check this. should select the total search results
  iterations = total_search_results/50 +1
  remainder_count = total_search_results%50

  url_to_iterate_on = $base_url + "/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&u=%2Fnetahtml%2FPTO%2Fsearch-adv.htm&r=0&f=S&l=50&d=PTXT&OS=AN%2F%22"+"#{modified_name}"+"%22&RS=AN%2F%22"+"#{modified_name}"+"%22&Query=AN%2F%22"+"#{modified_name}"+"%22&TD="+ "#{total_search_results}" +"&Srch1=%22"+"#{modified_name}"+"%22.ASNM.&NextList"+"#{page_number}"+"=Next+50+Hits"

  until page_number == iterations do
    get_html(url_to_iterate_on, id)
    page_number+= 1
  end
  if page_number == iterations
    final_url = $base_url + "/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&u=%2Fnetahtml%2FPTO%2Fsearch-adv.htm&r=0&f=S&l=50&d=PTXT&OS=AN%2F%22"+"#{modified_name}"+"%22&RS=AN%2F%22"+"#{modified_name}"+"%22&Query=AN%2F%22"+"#{modified_name}"+"%22&TD="+ "#{total_search_results}" +"&Srch1=%22"+"#{modified_name}"+"%22.ASNM.&NextList"+"#{page_number}"+"=Final+"+"#{remainder_count}"+"+Hits"
    get_html(final_url, id)
  end
end


def get_html(url, id)
page = Nokogiri::HTML(open(url)) #if Net::HTTP.get_response(url).code.match(/20\d/) #open page if response code is 200 something

  application = page.css("a") #grabbing links and text
  application.each do |x|
   if x.text.nil? || x.text.empty? #this should also check if the application number already exists in db. if not it grab the doc
     puts "failed" #i should change this
   else
     doc_url = $base_url + "#{x["href"]}" #add prefix so url is complete in db
     link_text = x.text.strip
     if link_text =~ /\A\d/ #checks if first character is digit
       app_number = link_text.gsub(",","" )
        if $db.execute("SELECT 1 FROM patent_listing WHERE application_number = :app_number LIMIT 1", app_number.to_s)
       puts "already in db"
          else get_patent_document_full_text(doc_url, app_number, id)
     end
  end
  end
  end
end


def get_patent_document_full_text(url_from_db, app_num, id)

    url = (url_from_db)
    semi_encoded_url = url.gsub('"', "%22")
    page = Nokogiri::HTML(open(semi_encoded_url))
    parse_patent_doc(page, app_num, id, page.to_s)
  end

def parse_patent_doc(noko_doc, app_num, id, raw_html)
    title = "#{noko_doc.css("font[size= '+1']").text}"
    description = "#{noko_doc.css("p")[0].text}"
    inventors = "#{get_inventors(noko_doc)}"
    filed_date = "#{noko_doc.css("td b")[3].text.strip}" #could use a regex checker if this proves inaccurate
    $db.execute("INSERT INTO patent_listing(entityid, application_number, raw_html, inventors, description, title, filed_date) VALUES (?,?,?,?,?,?,?)",id, app_num, raw_html, inventors, description, title, filed_date) #write parsed stuff to db
end

def get_inventors(document)
  inventor_names = Array.new
  i = 5
  a = document.css('tr td b')
  inventor_names << a[4].text
  while a[i].text =~ /\A,/
    inventor_names << a[i].text
    i += 1
  end
  inventor_list = inventor_names.join(",")
return inventor_list
end


get_patents_today