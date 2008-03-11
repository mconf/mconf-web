require File.dirname(__FILE__) + '/../test_helper'

class EventDatetimeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :events, :machines, :participants, :users, :event_datetimes
  
  def test_datetime_min_lenght
    a = event_datetimes(:event_datetime_00100)
    b = event_datetimes(:event_datetime_00013)
    c = event_datetimes(:event_datetime_00102)
    
    array = []
    array[0] = a
    array[0] = b
    array[0] = c
    
    assert_not_nil array
    assert !EventDatetime.datetime_min_length(array)
    
    
  end
  
  def test_datetime_max_lenght
    a = event_datetimes(:event_datetime_00100)
    b = event_datetimes(:event_datetime_00013)
    c = event_datetimes(:event_datetime_00102)
    
    array = []
    array[0] = a
    array[0] = b
    array[0] = c
    
    assert_not_nil array
    assert !EventDatetime.datetime_max_length(array)
    
    
  end
  
  def test_array_calendar
      arr = EventDatetime.array_calendar
      assert_not_nil arr

end
 
 
   end
