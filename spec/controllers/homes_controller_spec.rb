require "spec_helper"

describe HomesController do
  include ActionController::AuthenticationTestHelper

  render_views

  describe "#user_rooms" do
    let(:user) { Factory.create(:user) }
    let(:space) { Factory.create(:space) }
    let(:other) { Factory.create(:event) } # anything other than User or Space

    # creates the hash that represents the room owner in the json response
    def owner_hash(owner)
      if owner.nil?
        nil
      elsif owner.instance_of?(Space)
        { :type => "Space", :id => space.id, :name => space.name, :public => space.public? }
      elsif owner.instance_of?(User)
        { :type => "User", :id => user.id }
      else
        { :type => other.class.name, :id => other.id }
      end
    end

    let(:rooms) {
      [ Factory.create(:bigbluebutton_room, :owner => user),
        Factory.create(:bigbluebutton_room, :owner => space),
        Factory.create(:bigbluebutton_room, :owner => other),
        Factory.create(:bigbluebutton_room, :owner => nil) ]
    }
    let(:expected_json_response) {
      rooms.map{ |r|
        link = "/bigbluebutton/servers/#{r.server.to_param}/rooms/#{r.to_param}/join?mobile=1"
        { :bigbluebutton_room => { :name => r.name, :join_path => link, :owner => owner_hash(r.owner) } }
      }.to_json
    }
    before do
      login_as(user)
      controller.current_user.should_receive(:accessible_rooms).and_return(rooms)
    end

    before(:each) { get :user_rooms, :format => :json }

    it { should respond_with_content_type(:json) }
    it { should respond_with_json(expected_json_response) }
  end

end



