
class ConferenceController < ApplicationController

	KEY="123asd123"
	MARTE_URL="marte3.dit.upm.es"
	PATH="/MarteServer/rest/rooms"
	SERVICE_NAME="standalone"
	MAUTH_VERSION="3.1"
	#HTTP METHODS
	GET_METHOD="GET"
	POST_METHOD="POST"
	DELETE_METHOD="DELETE"
	
	
	def self.createRoom(room_name)
		data="<room><name>"+room_name+"</name></room>"		
		sendMessage(MARTE_URL, PATH, POST_METHOD, MAUTH_VERSION, SERVICE_NAME, data)
	end


	
	def self.sendMessage(address, path, method, mauth_version, service_name, data)
		
		#get the params to fill in the headers
		
		#timestamp without decimals
		timestamp=Time.now.to_i
		
		#cnonce, we use a randon number between 1 and 999.999.999
		cnonce=rand(1000000000)
		
		#now we prepare the signature. It is a HMAC:SHA1 of "timestamp,cnonce"
		to_sign="#{timestamp},#{cnonce}"
		puts "cosas pa firmar " + to_sign
		signature=Base64.b64encode(HMAC::SHA1.hexdigest(KEY, to_sign)).chomp.gsub(/\n/,'')
		
		
		#everything ready, create the message headers
		message = Net::HTTP::new(address)	
		headers = {
			"Content-Type" => "application/xml",
			"Authorization"=> "MAuth realm=\"#{address}\", mauth_signature_method=\"HMAC_SHA1\", mauth_serviceid=\"#{service_name}\",mauth_signature=\"#{signature}\",mauth_timestamp=\"#{timestamp}\",mauth_cnonce=\"#{cnonce}\",mauth_version=\"#{mauth_version}\""
		}
		
		puts headers
		
		case method
		when POST_METHOD
			resp, data = message.post(path, data, headers)
		when GET_METHOD
			resp, data = message.get(path, headers)
		when DELETE_METHOD
			resp, data = message.delete(path, headers)
		end
		
		# Output on the screen -> we should get either a 302 redirect (after a successful login) or an error page
		puts 'Code = ' + resp.code
		puts 'Message = ' + resp.message
		resp.each {|key, val| puts key + ' = ' + val}
		puts data

	end
	
	def self.destroyRoom(room_name)		
		sendMessage(MARTE_URL, PATH + "/" + room_name , DELETE_METHOD, MAUTH_VERSION, SERVICE_NAME, "")
  end

	def self.getRooms()
    sendMessage(MARTE_URL, PATH , GET_METHOD, MAUTH_VERSION, SERVICE_NAME, "")
  end
  
  def self.sendTokenMessage(address, path, mauth_version, service_name, roomName, userName, role)
    
    #get the params to fill in the headers
    
    #timestamp without decimals
    timestamp=Time.now.to_i

    #cnonce, we use a randon number between 1 and 999.999.999
    cnonce=rand(1000000000)
    
    #now we prepare the signature. It is a HMAC:SHA1 of "timestamp,cnonce"
    to_sign="#{timestamp},#{cnonce},#{userName},#{role}"
    signature=Base64.b64encode(HMAC::SHA1.hexdigest(KEY, to_sign)).chomp.gsub(/\n/,'')
    
    #everything ready, create the message headers
    message = Net::HTTP::new(address) 
    headers = {
      "Content-Type" => "application/xml",
      "Authorization"=> "MAuth realm=\"#{address}\", mauth_signature_method=\"HMAC_SHA1\", mauth_serviceid=\"#{service_name}\",mauth_signature=\"#{signature}\",mauth_timestamp=\"#{timestamp}\",mauth_cnonce=\"#{cnonce}\",mauth_version=\"#{mauth_version}\",mauth_username=\"#{userName}\",mauth_role=\"#{role}\""
    }    
    
    resp, data = message.post(path, " ", headers)

    return data    
  end  
  
  
	def self.getTokenForUser(roomName, userName,role)
    sendTokenMessage(MARTE_URL, PATH + "/#{roomName}/tokens",MAUTH_VERSION, SERVICE_NAME, roomName, userName, role)
	end
	
	
	
end

