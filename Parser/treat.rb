
require 'treat'
require 'boilerpipe'
include Treat::Core::DSL
 Treat.core.language.detect = true

def boilerpipe_text_extractor(url)
  Boilerpipe.extract(url, {:output => :text}) #extracts main article text from each article passed
end

def find_language(text)

end
   p = paragraph "Obama and Sarkozy met on January 1st to investigate the possibility of a new rescue plan." +
        "President Sarkozy is to meet Merkel next Tuesday in Berlin."
   puts p.language

    p.apply(:chunk, :segment, :tokenize, :name_tag).print_tree
    
    
    
    
    
    
    
    
    
    
    #this should allow me to retreive cluster of topics within documents
    #puts p.topic_words(
      #:lda,
      #:num_topics => 10,
     # :words_per_topic => 5,
      #:iterations => 20
 #   ).inspect
    
   
