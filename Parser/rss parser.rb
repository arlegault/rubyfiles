require 'feedjira'
require 'sqlite3'

db = SQLite3::Database.new("article_text.db")

db.results_as_hash = true #to iterate throuh feed array, we needed output to be a hash

feeds_array = db.execute("SELECT * FROM rss_feeds") #find all the feed links in the db

feeds_array.each do |row| #iterate through the array from the db to grab each feed link and source name
 feed_url = row['feed_link']
 source = row['feed_name']

feed = Feedjira::Feed.fetch_and_parse feed_url #save feedjira parsing results to a var. it grab each feed url from the above aray we are iterating on

feed.entries.each do |article| #takes each entries object which are arrays and grabs only the title and urls
  
  title = article.title #saving the parsed title to a var
  link = article.url #saving the parsed link to a var

matching_links_in_db = db.execute("SELECT * FROM raw_news WHERE link = ?", link) #looking to see if this story link exists in the db

if matching_links_in_db.length > 0 #if link exists in db, the array results will return larger than 1
  puts "The story at" + " " + link + " " + "already exists in db"
  
else puts "adding story to db"
  db.execute("INSERT INTO raw_news(link, date, time, source, title) VALUES (?, CURRENT_DATE, CURRENT_TIME, ?,?)", link, source, title)
#this execute writes any stories that do not exist in db, to the db
end
end
end

