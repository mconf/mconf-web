#TODO functions to perform: join, end meeting, 
#TODO what happens when the server is off?
#TODO check the returncode in every request

class BigBlueButtonAPI

  attr_accessor :server, :salt

  def initialize(attributes = {})
    #TODO what if server already has 'http' or 'bigbluebutton/'?
    @server = 'http://' + attributes[:server] + '/bigbluebutton/'
    @salt = attributes[:salt]
  end

  def create(meeting_name)
    url = get_create_link(meeting_name)
    send_request(url)
  end

  def get_create_link(meeting_name)
    #TODO all parameters below should be configurable
    params = { :name => meeting_name, :meetingID => meeting_name,
               :welcome => 'Bem-vindo!', :attendeePW => 'ap', :moderatorPW => 'mp',
               :voiceBridge => (70000 + rand(9999)).to_s }
    get_link('create', params)
  end

  def is_meeting_running?(meetingID)
    url = get_is_meeting_running_link(meetingID)
    response = send_request(url)
    response[:running]
  end

  def get_is_meeting_running_link(meetingID)
    params = { :meetingID => meetingID }
    get_link('isMeetingRunning', params)
  end

  def get_meeting_info(meetingID, password)
    url = get_meeting_info_link(meetingID, password)
    send_request(url)
  end

  def get_meeting_info_link(meetingID, password)
    params = { :meetingID => meetingID, :password => password }
    get_link('getMeetingInfo', params)
  end


  private

  def send_request(url)
    puts 'Sending request to: ' + url
    doc = open(url)
    hash = Hash.from_xml doc
    # remove the "response" node and convert all keys to symbols
    Hash[hash["response"]].inject({}){|h,(k,v)| h[k.to_sym] = v; h}
    # Hash[*doc.xpath("/response/*").map { |v| [v.name.parameterize.underscore.to_sym, v.text] }.flatten]
  end

  def get_link(method, params = {})
    #TODO validate method in { join, create, isMeetingRunning, ... }
    # ['Mr.', 'Mrs.', 'Dr.'].include?(value)
    base_url = @server + "api/#{method}?"
    url_params = params.map{ |k,v| "#{k}=" + CGI::escape(v) }.join("&")
    url = base_url + url_params

    checksum = Digest::SHA1.hexdigest( method + url_params + @salt )
    url = url + '&checksum=' + checksum
  end

end
