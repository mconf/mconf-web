   class MarteToken < ActiveResource::Base
	  self.site = "http://marte3.dit.upm.es/MarteServer/rest/rooms/:room_id"
	  self.element_name = "token"
	  
	  KEY="123asd123"	
	  SERVICE_NAME="standalone"
	  MAUTH_VERSION="3.1"
	  MARTE_URL="marte3.dit.upm.es"
	  
	  
	  #new is called MarteToken.new(:username=>'pepe', :role=>'admin', {:room_id=>'room_name'})
	  #save is called MarteToken.save
	  #create is called MarteToken.create(:username=>'pepe', :role=>'admin', {:room_id=>'room_name'})
	  #delete is called MarteToken.delete(id)
	  #show is called MarteToken.find(:all)
	  
	  
	  
	  #define the headers to add Authentication
	  def self.headers
		#debugger
		#get the params to fill in the headers
		userName=@attributes[:username]
		role=@attributes[:role]
		
		#timestamp without decimals
		timestamp=Time.now.to_i
		
		#cnonce, we use a randon number between 1 and 999.999.999
		cnonce=rand(1000000000)
		
		#now we prepare the signature. It is a HMAC:SHA1 of "timestamp,cnonce,username,role"
		to_sign="#{timestamp},#{cnonce},#{userName},#{role}"
		extra_header=",mauth_username=\"#{userName}\",mauth_role=\"#{role}\"" 
		
		puts "cosas pa firmar " + to_sign
		signature=Base64.b64encode(HMAC::SHA1.hexdigest(KEY, to_sign)).chomp.gsub(/\n/,'')
		
		#everything ready, create the message headers			
		headers = {
			"Content-Type" => "application/xml",
			"Authorization"=> "MAuth realm=\"#{MARTE_URL}\", mauth_signature_method=\"HMAC_SHA1\", mauth_serviceid=\"#{SERVICE_NAME}\",mauth_signature=\"#{signature}\",mauth_timestamp=\"#{timestamp}\",mauth_cnonce=\"#{cnonce}\",mauth_version=\"#{MAUTH_VERSION}\"#{extra_header}"
		}		
		
		puts headers
	end
   end
