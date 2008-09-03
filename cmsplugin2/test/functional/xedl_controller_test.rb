require File.dirname(__FILE__) + '/../test_helper'

class XedlControllerTest < ActionController::TestCase

  def test_create_xedl()
    session_string = XedlController.create_session(1.9,"EditedSession","Isabel",
                               "class.act","512K","false")
    options_string = XedlController.create_options("triton","", "122","triton.dit.upm.es")
    options_string2 = XedlController.create_options("gecko","", "203","gecko.dit.upm.es","triton.dit.upm.es", "interactive","10","1")
    sites = [options_string,options_string2]
    create_xedl(session_string,sites)
  end


  def create_xedl(session_string,sites)
      XedlController.create_xedl(session_string,sites)    
  end
  
  
  def test_create_session_default
    create_session_and_compare
  end
  
  
  def test_create_session_good
    create_session_and_compare("EditedSession.xedl",1.9,"EditedSession","Isabel",
                               "class.act","512K","false")
  end
  
  
  #method to create a session and compare the resulting string with the content
  #of a file also given
  def create_session_and_compare(filename="MySession.xedl",version=1.8,id="MySession",delivery_platform="Isabel",
                  service_name="meeting.act",service_quality="1M",open_session="true")
    xedl_session = XedlController.create_session(version,id,delivery_platform,
                              service_name,service_quality,open_session)
    #depending on whether you execute this rb file or run the rake program
    #you will need a different path for the file MySession.xedl
    path_to_file = ""
    if File.exist?(filename)
      path_to_file = filename
    else
      path_to_file = "test/xml/#{filename}"
    end
    #split the xedl string we got by newlines, 
    #we will have to delete the \n characters before
    xedl_lines = xedl_session.split(/$/)
    indice = 0
    File.open(path_to_file).each do |line|
      assert_equal line.chomp, xedl_lines[indice].delete("\n")
      indice += 1
    end
  end
  
  
  def setup
    @controller = XedlController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  
  #this method tests the create_options passing it the compulsory options and the default options
  #further tests will try with other values
  def test_create_options_default    
        options_string = XedlController.create_options("triton","", "122","triton.dit.upm.es")
        assert options_string.include?("<ID>triton</ID>")
        assert options_string.include?("<SITE-ROLE>mcu</SITE-ROLE>")
  end 
  
  
  def test_create_options_with_all_params
        options_string = XedlController.create_options("gecko","", "203","gecko.dit.upm.es","triton.dit.upm.es", "interactive","10","1")
        assert options_string.include?("<ID>gecko</ID>")
        assert options_string.include?("<SITE-ROLE>interactive</SITE-ROLE>")
        assert options_string.include?("<n>11</n>")
        
  end
    
end
  