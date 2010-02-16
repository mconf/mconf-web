require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  it "should work with Station container_and_ancestors method" do
    @event = Factory(:event_public)
    assert_equal @event.container_and_ancestors, [ @event, @event.space ]
  end
end


