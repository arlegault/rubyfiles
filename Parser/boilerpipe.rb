require 'boilerpipe'
require 'sqlite3'

db=SQLite3::Database.new("article_text.db")

def boilerpipe_text_extractor(url)
Boilerpipe.extract(url, {:output => :text}) #extracts main article text from each article passed
end

db.results_as_hash = true #to iterate throuh feed array, we needed output to be a hash

stories_from_db = db.execute("SELECT * FROM raw_news") #find all the feed links in the db

stories_from_db.each do |row| #iterate through the array from the db to grab each feed link and source name
 story_link = row['link']
 art_txt = row['article_txt']

  if art_txt.nil? || art_txt.empty?
  puts "writing article text to db"
  text = boilerpipe_text_extractor(story_link)

db.execute( "UPDATE raw_news SET article_txt= :text WHERE link= :story_link", text, story_link)

sleep 1 #API will thorttle if calls are closer than .7 

else puts "already in db"

end 
end




