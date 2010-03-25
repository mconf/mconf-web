module VenusXmlParser

  class Participation
    
    def initialize
       @tags = []    
#       puts "VenusXmlParserParticipation Created"
    end
        
    def addTag(tag)
      @tags << tag
    end
    
    
    def getAuthors   
        
        names = []
        
        @tags[0].elements.each("metadata/author"){
          |author|
          names << author.attributes["name"]
        } 
        
#        principalAuthor = @tags[0].attributes["name"]
        
        names   
    end
    
    
    def getBio(author)
      
        @tags[0].elements.each("metadata/author"){
          |author_element|
          
          if(author_element.attributes["name"] == author)
            return author_element.attributes["bio"]
          end
       
        }
        
        return nil
        
    end
    
    def getTagsLength    
      return @tags.length     
    end   
    
    def getDate
         @tags[0].elements["metadata/startedBy"].attributes["date"]
    end
    
    def print
      @tags.each do |tag|
        puts tag
      end
    end
    
     def getXmlId
      @tags[0].attributes["id"]  
    end
    
    def getSource
      @tags[0].attributes["src"]  
    end
    
    def getClipBegin
      @tags[0].attributes["clipBegin"]  
    end
    
    def getClipEnd
      @tags[0].attributes["clipEnd"]  
    end
    
    def getTitle
      @tags[0].attributes["title"]  
    end
  
  end
  
end