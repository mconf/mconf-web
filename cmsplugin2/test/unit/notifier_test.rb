require File.dirname(__FILE__) + '/../test_helper'

class NotifierTest < ActionMailer::TestCase
  fixtures :events, :machines, :participants, :users, :event_datetimes
  tests Notifier
  # replace this with your real tests
  def test_truth
    assert true
  end
  def test_contact_mail
    
  end
end
