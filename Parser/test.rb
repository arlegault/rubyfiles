require 'nokogiri'
require 'open-uri'

$base_url = "http://patft.uspto.gov"
def get_search_url(name, id)
  modified_name = name.strip.gsub(/\s/, "+")
  page_number = 2 #this is a place holder for now. need to increment the url
  initial_search = $base_url + "/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&p=1&u=%2Fnetahtml%2FPTO%2Fsearch-bool.html&r=0&f=S&l=50&TERM1=" + modified_name+"&FIELD1=ASNM&co1=AND&TERM2=&FIELD2=&d=PTXT"
  page = Nokogiri::HTML(open(initial_search))
  total_search_results = page.css("strong")[2].text.to_i #double check this. should select the total search results
  iterations = total_search_results/50 +1
  final_list = total_search_results%50

  url_to_iterate_on = $base_url + "/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&u=%2Fnetahtml%2FPTO%2Fsearch-adv.htm&r=0&f=S&l=50&d=PTXT&OS=AN%2F%22"+"#{modified_name}"+"%22&RS=AN%2F%22"+"#{modified_name}"+"%22&Query=AN%2F%22"+"#{modified_name}"+"%22&TD="+ "#{total_search_results}" +"&Srch1=%22"+"#{modified_name}"+"%22.ASNM.&NextList"+"#{page_number}"+"=Next+50+Hits"

  until page_number == iterations do
    puts url_to_iterate_on
    page_number+= 1
  end
  if page_number == iterations
    final_url = $base_url + "/netacgi/nph-Parser?Sect1=PTO2&Sect2=HITOFF&u=%2Fnetahtml%2FPTO%2Fsearch-adv.htm&r=0&f=S&l=50&d=PTXT&OS=AN%2F%22"+"#{modified_name}"+"%22&RS=AN%2F%22"+"#{modified_name}"+"%22&Query=AN%2F%22"+"#{modified_name}"+"%22&TD="+ "#{total_search_results}" +"&Srch1=%22"+"#{modified_name}"+"%22.ASNM.&NextList"+"#{page_number}"+"=Final+"+"#{final_list}"+"+Hits"
    puts final_url
  end
end

get_search_url("Linkedin Corporation", 1)