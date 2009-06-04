   class MarteRoom < ActiveResource::Base
	self.site = "http://marte3.dit.upm.es/MarteServer/rest"
	self.element_name = "room"
	
	
	#KEY="123asd123"	
	#SERVICE_NAME="standalone"
	KEY="GlobalRules1234"	
	SERVICE_NAME="global"
	MAUTH_VERSION="3.1"
	MARTE_URL="marte3.dit.upm.es"
	
	#new is called sala = MarteRoom.new :name=> 'name'
	#save is called sala.save
	#create is called sala = MarteRoom.create :name=> 'name'
	#destroy is called MarteRoom.find('name').destroy
	#show is called MarteRoom.find(:all)
	
	
	
	#define the headers to add Authentication
	def self.headers
		#get the params to fill in the headers
		
		#timestamp without decimals
		timestamp=Time.now.to_i
		
		#cnonce, we use a randon number between 1 and 999.999.999
		cnonce=rand(1000000000)
		
		#now we prepare the signature. It is a HMAC:SHA1 of "timestamp,cnonce"
		to_sign="#{timestamp},#{cnonce}"
		
		signature=Base64.b64encode(HMAC::SHA1.hexdigest(KEY, to_sign)).chomp.gsub(/\n/,'')
		
		#everything ready, create the message headers			
		headers = {
			"Content-Type" => "application/xml",
			"Authorization"=> "MAuth realm=\"#{MARTE_URL}\", mauth_signature_method=\"HMAC_SHA1\", mauth_serviceid=\"#{SERVICE_NAME}\",mauth_signature=\"#{signature}\",mauth_timestamp=\"#{timestamp}\",mauth_cnonce=\"#{cnonce}\",mauth_version=\"#{MAUTH_VERSION}\""
		}
	end
	
	
	#redefined to remove format.extension
        def self.collection_path(prefix_options = {}, query_options = nil)
            prefix_options, query_options = split_options(prefix_options) if query_options.nil?
            "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
        end

	def self.element_path(id, prefix_options = {}, query_options = nil)
		prefix_options, query_options = split_options(prefix_options) if query_options.nil?
           "#{prefix(prefix_options)}#{collection_name}/#{id}#{query_string(query_options)}"
     	end
    
		def self.instantiate_collection(collection, prefix_options = {}) 
		          if collection.is_a?(Hash) && collection.size == 1 
 		            value = collection.values.first 
 		            if value.is_a?(Array) 
 		              value.collect! { |record| instantiate_record(record, prefix_options) } 
 		            else 
 		              [ instantiate_record(value, prefix_options) ] 
 		            end 
 		          elsif collection.is_a?(Hash) 
 		            instantiate_record(collection, prefix_options) 
 		          else 
 		            collection.collect! { |record| instantiate_record(record, prefix_options) } 
 		          end 
	end 
  end

