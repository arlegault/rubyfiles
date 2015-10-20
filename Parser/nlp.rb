
require 'sqlite3'
require 'stanford-core-nlp'

# db=SQLite3::Database.new("article_text.db")
# db.execute( SELECT * from raw_news)

text = 'Angela Merkel met Nicolas Sarkozy on January 25th in ' +
   'Berlin to discuss a new austerity package. Sarkozy ' +
   'looked pleased, but Merkel was dismayed.'
  
pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
text = StanfordCoreNLP::Annotation.new(text)
pipeline.annotate(text)

 puts text.get(:coref_chain).class.name

 
 
 #need to call the mention in this tag
text.get(:sentences).each do |sentence|
  # Syntatical dependencies
puts sentence.get(:basic_dependencies).to_s
puts sentence.get(:coref_chain)
  sentence.get(:tokens).each do |token|
    # Named entity tag
if token.get(:named_entity_tag).to_s == "PERSON" 
  #puts token
 # puts token.get(:lemma).to_s
  #puts token.get(:named_entity_tag).to_s
end #need to redo db for tbale association to support entities (rowid, entity id, name)
    # Coreference
    # Also of interest: coref, coref_chain,
    # coref_cluster, coref_dest, coref_graph.
#need to put all entity/persons in an array then iterate through the array looking at each coref id. put all the same coref id's in the same array
end 
  end
 