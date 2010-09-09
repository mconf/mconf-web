namespace :chat_logs do
  desc "Save chat log for the past events"
  task(:save => :environment) do
    Event.all(:conditions => ["end_date > ?", Date.today - 2]).each do |event|
      begin
        if event.chat_log.nil?
          url_string = "http://#{Site.first.presence_domain}:9090/plugins/vccRooms?event-name=#{event.permalink}"
          url = URI.parse(url_string)
          
          req = Net::HTTP::Get.new(url.to_s)
          vccUser = Site.current.vcc_user_for_chat_server
          vccPass = Site.current.vcc_pass_for_chat_server
          
          if (vccUser.nil?)
            raise "Error Vcc User for Chat Server authentication is not set"
          end
          
          req.basic_auth vccUser, vccPass
          
          res = Net::HTTP.start(url.host, url.port) do |http|
            http.request(req)
          end
          
          if res.class == Net::HTTPOK
            chat_content =  res.body
            if not chat_content.empty?
              event.chat_log = ChatLog.new( :content => res.body )
              event.save          
            end
          else
            debugger
            raise "Error getting chat log for event " + event.permalink + " with id " + event.id.to_s 
          end
        end
      rescue Exception => e
        puts e.message
      end
    end
  end
end