require 'net/http'
require 'json'

uri = URI.parse("https://ussouthcentral.services.azureml.net/workspaces/a0e65d42d21c423fa4027d98f6ad364f/services/0d797f1b26d4410cae35c50d25d1c7cd/execute?api-version=2.0&details=true")
apikey = "ycmEz6IhmaQvGfMyUukHy03X0hGHGT9+/5EdaXJG7AZvAkZK37a5qJU6YkqPhY+rTbKaDGHxwIbisqAJUl88yA=="

header = {'Content-Type'=> 'application/json', 'Content-Length'=> '235', 'Authorization'=> "Bearer" + " " + apikey}


@toSend = {
    "date" => "2012-07-02",
    "aaaa" => "bbbbb",
    "cccc" => "dddd"
}.to_json


http = Net::HTTP.new(uri.host,uri.port)

req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json', 'Content-Length'=> '235', 'Authorization'=> "Bearer" + " " + apikey})

req.body = "[ #{@toSend} ]"
res = http.request(req)
puts "Response #{res.code} #{res.message}: #{res.body}"


