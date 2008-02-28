require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :events, :machines, :participants, :event_datetimes, :users
  
  def test_name
   evento = events(:event_00038 )
    assert evento.valid?
    #assert_equal "should expecify a name", evento.errors.on(:name)
  end
  def test_if_a_machines_is_in_an_event
    evento = events(:event_00038 )    
    trapo = machines(:machine_00005).id    
    assert evento.uses_participant(trapo)
  end
  
  def test_if_many_machines_are_in_an_event
    evento = events(:event_00038 )  
  end
  

    def test_get_url_complejo
      evento = events(:event_00040 )  
    trapo = machines(:machine_00005).nickname
     golpe = machines(:machine_00008).nickname
    traste = machines(:machine_00009).nickname
    url = []
    url[0]= "isabel://"+ trapo
     url[1]= "isabel://"+ golpe
      url[2]= "isabel://"+ traste
       urls = evento.get_urls
       assert_not_nil urls
    assert_equal url, urls
  end
  
  def test_overlaps_with_event
    evento = events(:event_00040 ) 
    evento2 = events(:event_00042 ) 
    evento3 = events(:event_00041 )
    even = []
    even[0]= evento2
    even[1]= evento3
    even2 = []
    even2[0] = evento3
    
    assert evento.overlaps_with_event_in_array(even)
    #assert evento.overlaps_with_event_in_array(even2)
    
  end
  
  def test_has_any_session_in_the_past
    evento = events(:event_00040 ) 
    assert evento.has_any_session_in_the_past
  end
  
  

end
