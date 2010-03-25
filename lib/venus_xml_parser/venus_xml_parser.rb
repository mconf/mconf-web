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


#      doc = REXML::Document.new file
  
  #   puts doc 
  #   puts "\n Impresion del documento finalizada \n"
  #   puts " "
   
      sequences = []
      @participations = []
   
      doc.elements.each("//seq"){ 
        |seq| 
        #puts seq.attributes["name"]
        sequences << seq
      }
  
      if sequences.length == 1
        @seq = sequences[0];
      else
        puts "More or less than 1 sequence... ¿Valid case?"
        puts "Syntax error"
        return
      end
   
      #New actions
      
      @participations = VenusXmlParser.generateParticipations(@seq)
   
   
      puts "VenusXmlParser Created [OK]"
        
    end
    
    
    def self.imprimeTag(tag)
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
          
       #tag.elements.each("*/startedBy")
       tag.elements.each("metadata/startedBy"){
        |started|
   
        if(started.attributes["event"] == "participation_init")
            return true;
        end    
         
       }
       
       return false  
      
    end
    
    def self.hasParticipationEnd(tag)
          
       #tag.elements.each("*/startedBy")
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
#          puts "Has participation init" 
          participation.addTag(video)
          moreTags = true
  
        else
#          puts "No Has participation init"
          
          if moreTags
            participation.addTag(video)
          
            if VenusXmlParser.hasParticipationEnd(video)
#              puts "Has participation end"
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
    
    
    def getParticipationsNames
      
      participationsNames = []
      
      @participations.each do |participation|  
          participationsNames << participation.getAuthor        
      end  
      
      participationsNames
  
    end
    
    
    def printParticipationTags 
      i = 1
      @participations.each do |participation|     
        3.times do
          puts ""
        end  
        puts "Participation " + i.to_s()
        puts participation.imprime     
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