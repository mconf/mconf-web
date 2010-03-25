require "rexml/document"
include REXML

module VenusXmlParser

  class VenusXmlParser
    
    def initialize(path)     
        
      if VenusXmlParser.isUrl(path)
        xml_data = Net::HTTP.get_response(URI.parse(path)).body     
      else
        xml_data = File.new(path);
      end
        
      doc = REXML::Document.new(xml_data)
   
      sequences = []
      @participations = []
   
      doc.elements.each("//seq"){ 
        |seq| 
        sequences << seq
      }
  
      if sequences.length == 1
        @seq = sequences[0];
      else
        puts "Xml format error"
        return nil
      end
   
      #Actions
      
      @participations = VenusXmlParser.generateParticipations(@seq)
   
      puts "VenusXmlParser Created [OK]"
        
    end
    
    def self.printTag(tag)
      puts ""
      puts tag
      puts ""
    end
    
    def self.isUrl(path)
      if path.include? "http://" or path.include? "https://"
        return true;
      else
        return false;
      end
    end
    
    def self.hasParticipationInit(tag)
          
       tag.elements.each("metadata/startedBy"){
        |started|
   
        if(started.attributes["event"] == "participation_init")
            return true;
        end    
         
       }
       
       return false  
      
    end
    
    def self.hasParticipationEnd(tag)
          
      tag.elements.each("metadata/startedBy"){
        |started|
      
        if(started.attributes["event"] == "participation_end")
            return true;
        end    
         
      }
       
      return false  
      
    end
    
    def self.generateParticipations(seq)
      
      participation = Participation.new
  
      participations = []      
      moreTags = false;
      
      seq.elements.each{
        |video|
      
        if VenusXmlParser.hasParticipationInit(video)
          participation.addTag(video)
          moreTags = true
  
        else
          
          if moreTags
            participation.addTag(video)
          
            if VenusXmlParser.hasParticipationEnd(video)
              participations << participation
              participation = Participation.new
              moreTags = false
            end
          
          end
          
        end
  
      }
   
      participations
      
    end
    
    
    def getParticipations
      @participations   
    end
    
    
    def getParticipationNames
      
      participationNames = []
      
      @participations.each do |participation|  
          participationsNames << participation.getAuthor        
      end  
      
      participationNames
  
    end
    
    
    def printParticipationTags 
      i = 1
      @participations.each do |participation|     
        3.times do
          puts ""
        end  
        puts "Participation " + i.to_s()
        puts participation.print     
        i = i+1
      end     
    end
    
    #Return participations of one author.
    def findParticipation(author)
      participations = []
      
      @participations.each do |participation|
        authorsList = participation.getAuthors
        
        authorsList.each do |author_item|
          if author_item == author
            participations << participation
          end
        end
       
      end
      
      participations
    end
  
  end

end