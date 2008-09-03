class XedlController < ApplicationController
   before_filter :authorize
  #array of forward error correcting, with the values for n and k
    FEC = {
      0=>[0,0],
      10=>[11,10],
      25=>[5,4],
      50=>[3,2],
      100=>[2,1]
    }
    
  
  def self.create_xedl(session_string, sites)
    @xedl = ""
    xml_builder = Builder::XmlMarkup.new(:target=>@xedl, :indent=>3)
    xml_builder.instruct! :xml, :version=>"1.0", :encoding =>"ISO-8859-1"
    xml_builder.EDL("xmlns:xsi" =>"http://www.w3.org/2001/XMLSchema-instance",          
      "xsi:noNamespaceSchemaLocation"=>"file:/usr/local/isabel/lib/xedlsplitter/edl1-8.xsd"){
      |xedl| xedl << session_string
      xml_builder.tag!("site-description"){
        i=0
        while i<sites.size
          xml_builder << sites[i]
          i += 1
        end
      }
      #in the end we add the tag URL because it is compulsory
      xml_builder.URL("")
    }    
    @xedl
  end
  
  
  #method to create a session xedl with the params specified
  #returns a string with the content of the xedl defining the session
  def self.create_session(version=1.9,id="MySession",delivery_platform="Isabel SIR",service_name="meeting.act",
                      service_quality="1M",open_session="true")
      @xedl = ""
      xml_builder = Builder::XmlMarkup.new(:target=>@xedl, :indent=>3)
      #xml_builder.instruct! :xml, :version=>"1.0", :encoding =>"ISO-8859-1"
        xml_builder.VERSION(version)
        xml_builder.SESSION{
            xml_builder.ID(id)
            xml_builder.DELIVERY_PLATFORM(delivery_platform)
            xml_builder.SERVICE{
              xml_builder.tag!("SERVICE-NAME",service_name)
              xml_builder.tag!("SERVICE-QUALITY",service_quality)
            }
            xml_builder.tag!("session-info"){
              xml_builder.OPEN_SESSION(open_session)
            }
        }         
      @xedl      
  end
  
  
  #method that creates the options string to introduce in the database
  #nowadays it can be configured with id, password, location, role ,FEC and radiate_multicast
  #password can be nil or any string (if it is nil there is no password for this session)
  #role can be interactive or mcu (Flowserver)
  #fec can be 0, 10, 25, 50 or 100 (in percentage of fec)
  #radiate_multicast can be 0(false) or 1 (true)
  #returns the string with the content of the xml defining the options
  def self.create_options(id,password,location,address,address_connected_to=nil,role="mcu",fec=0,radiate_multicast=0)
      @options_xml = ""
      xml_builder = Builder::XmlMarkup.new(:target=>@options_xml, :indent=>3)
      xml_builder.SITE{
        xml_builder.tag!("site-identification"){
          xml_builder.ID(id)
          if password && password!=""
            logger.debug("SESSION CON PASSWORD")
            #the password is stored in the xedl encrypted with openssl, so we have to do it here because 
            #we have it clear
            password = encrypt_password(id,password)
            xml_builder.ACCESS_CONTROL(password)
          end
          xml_builder.PUBLIC_NAME(id+"."+location)
          xml_builder.SITE_ADDRESS(address)          
        }      
        xml_builder.tag!("SITE-ROLE",role)
        xml_builder.tag!("CONNECTION-MODE"){
          if address_connected_to
            xml_builder.mcu{
              xml_builder.MCU_ADDRESS(address_connected_to)
            }
          end
          if radiate_multicast==1
            xml_builder.multicast{
              xml_builder.tag!("multicast-parameters")
            }
          end
          }
        xml_builder.tag!("connection-parameters"){
          xml_builder.upanddownbandwidth{
            xml_builder.UPBANDWIDTH(1000)
            xml_builder.DOWNBANDWIDTH(1000)
        }
        
        
        if fec != 0
          xml_builder.PROTECTION{
            xml_builder.parity{
              xml_builder.n(FEC[fec.to_i][0])
              xml_builder.k(FEC[fec.to_i][1])
            }
          }
        end
      }
      xml_builder.tag!("NETWORK-ACCESS"){
        xml_builder.Ethernet("true")
      }
      if role == "mcu"
        xml_builder.ENABLE_MCU("true")
      end
      
      #in the end we have to add SITE_ADDITIONAL_PARAMS, because it is compulsory
      xml_builder.tag!("SITE_ADDITIONAL_PARAMS"){
        xml_builder.ISABEL_AUDIOMIXER("false")
      }
      
    }
      #we return the xml generated
      @options_xml
  end
  
 
  private
  #command = "openssl enc -des -e -a -A -pass pass:" + passPhrase << password
  #passPhrase is "error" + the_site_name
  def self.encrypt_password(id,password)
    logger.debug("echo \""+ password +"\" | openssl enc -des -e -a -A -pass pass:error" + id)
    pipe = IO.popen("echo \""+ password +"\" | openssl enc -des -e -a -A -pass pass:error" + id, "r")
    return pipe.read
  end

  
end