require "spec_helper"

describe HomesController do
  include ActionController::AuthenticationTestHelper

  render_views

  # TODO
  # superuser
  # normal user
  # anonymous user

  describe "#user_rooms" do
    let(:user) { Factory.create(:user) }
    let(:rooms) {
      [ Factory.create(:bigbluebutton_room),
        Factory.create(:bigbluebutton_room),
        Factory.create(:bigbluebutton_room) ]
    }
    before do
      login_as(user)
      controller.current_user.should_receive(:accessible_rooms).and_return(rooms)
    end

    before(:each) { get :user_rooms, :format => :json }

    it { should respond_with_content_type(:json) }
    it { should respond_with_json(rooms.to_json) }
  end

end


