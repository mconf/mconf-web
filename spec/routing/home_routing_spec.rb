require "spec_helper"

describe HomesController do
  include Shoulda::Matchers::ActionController

  describe "routing" do
    it { should route(:get, "/home").to(:action => :show) }
    it { should route(:get, "/home/user_rooms.json").to(:action => :user_rooms, :format => :json) }
    it { should_not route(:get, "/home/user_rooms.html").to(:action => :user_rooms) }
  end
end
