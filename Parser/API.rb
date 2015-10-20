require 'unirest'
require 'json'

uri = "https://ussouthcentral.services.azureml.net/workspaces/a0e65d42d21c423fa4027d98f6ad364f/services/0d797f1b26d4410cae35c50d25d1c7cd/execute?api-version=2.0&details=true"
apikey = "ycmEz6IhmaQvGfMyUukHy03X0hGHGT9+/5EdaXJG7AZvAkZK37a5qJU6YkqPhY+rTbKaDGHxwIbisqAJUl88yA=="

case_number = 1034757
case_type = "CITATION"
address = "8303 RENTON AVE S"
description = "A rooster."
case_group = "ZONING" 
date_case = ""
last_inspection_date = ""
last_inspection_result = ""  
status = "OPEN"
permit = "http://web1.seattle.gov/dpd/PermitStatus/Project.aspx?id=1034751"
lat = 47.52908176
long = -122.27843431
location = "(47.52908176, -122.27843431)"
# these variables will take the values entered via the form from the user and pass them to the request body

form_submission = [case_number, case_type, address, description, case_group, date_case, last_inspection_date, last_inspection_result, status, permit, lat, long, location] # this array stores the form responses that are passed in the api body call

response = Unirest.post uri, headers:{"content-length" => "500", "content-type" => "application/json", "authorization" => "Bearer" + " " + apikey}, parameters: {"Inputs" => {"input1" => {"ColumnNames" => ["Case Number", "Case Type", "Address", "Description", "Case Group", "Date Case Created", "Last Inspection Date", "Last Inspection Result", "Status", "Permit and Complaint Status URL", "Latitude", "Longitude", "Location"], "Values" => [form_submission ,form_submission]}}, "GlobalParameters" => {}}.to_json
# headers do not need to change unless we want to change the output content type from json to something else
# the column names remain constant so I could leave the in the response call. Maybe refactor out of the call?

puts response.code # Status code
puts response.headers # Response headers
puts response.body # Parsed body
response.raw_body # Unparsed body

#have to write something that will display the response in a view to the user


