require 'matrix'
require 'tf-idf-similarity'
require 'narray'
require 'sqlite3'

db=SQLite3::Database.new("companytext.db")
db.results_as_hash = true
def calc_similarity
corpus = Array.new

get_db_rows = db.execute("SELECT * FROM companies")
get_db_rows.each do |row| #iterate through db
  description = row['description_text']
  company = row['company_name']
  url = row['url']
  description.to_s
  doc = TfIdfSimilarity::Document.new(description) #this turns description into doc for use in simlairty
  corpus.push([company, doc])
#write place in array to db to associated entitiy to i can find it later
end
store = Array.new
corpus.each do |y|
#puts y[0]
#puts y[1]
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