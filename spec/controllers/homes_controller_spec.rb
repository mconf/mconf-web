require "spec_helper"

describe HomesController do
  include ActionController::AuthenticationTestHelper

  render_views

  describe "#user_rooms" do
    let(:user) { Factory.create(:user) }
    let(:rooms) {
      [ Factory.create(:bigbluebutton_room),
        Factory.create(:bigbluebutton_room),
        Factory.create(:bigbluebutton_room) ]
    }
    let(:expected_json_response) {
      rooms.map{ |r|
        link = "/bigbluebutton/servers/#{r.server.to_param}/rooms/#{r.to_param}/join.mobile"
        { :bigbluebutton_room => { :name => r.name, :join_path => link } }
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


