require "spec_helper"

describe HomesController do
  include ActionController::AuthenticationTestHelper

  render_views

  describe "#user_rooms" do

    context "returns the user room, user space's rooms and public space's rooms" do
      let(:user) { Factory.create(:user) }
      let(:space) { Factory.create(:space) }
      let(:space_not_member) { Factory.create(:space) }
      let(:other) { Factory.create(:event) } # anything other than User or Space

      # creates the hash that represents the room owner in the json response
      def owner_hash(owner)
        if owner.nil?
          nil
        elsif owner == space
          { :type => "Space", :id => space.id, :name => space.name,
            :public => space.public?, :member => true }
        elsif owner == space_not_member
          { :type => "Space", :id => space_not_member.id, :name => space_not_member.name,
            :public => space_not_member.public?, :member => false }
        elsif owner == user
          { :type => "User", :id => user.id }
        else
          { :type => other.class.name, :id => other.id }
        end
      end

      # one user room
      # one space room (the user is a member of this space)
      # one space room (the user is NOT a member of this space)
      # one "other" room
      # one room with no owner
      let(:rooms) {
        [ Factory.create(:bigbluebutton_room, :owner => user),
          Factory.create(:bigbluebutton_room, :owner => space),
          Factory.create(:bigbluebutton_room, :owner => space_not_member),
          Factory.create(:bigbluebutton_room, :owner => other),
          Factory.create(:bigbluebutton_room, :owner => nil) ]
      }
      let(:expected_json_response) {
        rooms.map{ |r|
          link = "/bigbluebutton/rooms/#{r.to_param}/join?mobile=1"
          { :bigbluebutton_room => { :name => r.name, :join_path => link, :owner => owner_hash(r.owner) } }
        }.to_json
      }
      before do
        Factory(:user_performance, :stage => space, :agent => user) # add user to space
        login_as(user)
        controller.current_user.should_receive(:accessible_rooms).and_return(rooms)
      end

      before(:each) { get :user_rooms, :format => :json }

      it { should respond_with_content_type(:json) }
      it { should respond_with_json(expected_json_response) }
    end

  end

  context "returns empty if accessible_rooms returns empty" do
    before do
      login_as(Factory.create(:user))
      controller.current_user.should_receive(:accessible_rooms).and_return(nil)
    end
    before(:each) { get :user_rooms, :format => :json }
    it { should respond_with_content_type(:json) }
    it { should respond_with_json([].to_json) }
  end

end



