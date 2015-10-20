#this file is meant to call tweets via the twitter API and eventually write them to a DB for later use.

require "open-uri"

remote_base_url = "http://api.twitter.com/1/statuses/user_timeline.xml?count=100&screen_name="
twitter_user = "USAGov"
remote_full_url = remote_base_url + twitter_user

tweets = open(remote_full_url).read

my_local_filename = twitter_user + "-tweets.xml"
my_local_file = open(my_local_filename, "w")
    my_local_file.write(tweets)    
my_local_file.close

#the code above is from rubybastrds. rewrite using current twitter API call standards