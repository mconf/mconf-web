require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :events, :machines, :participants
  
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
  
end
