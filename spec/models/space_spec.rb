# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Space do
  let(:space) { FactoryGirl.create(:space) }

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:space).should be_valid
  end

  describe "initializes with default values" do
    it("should be false by default") { Space.new.repository.should be_falsey }
    it("should be true if set to") { Space.new(:repository => true).repository.should be true }
    it("should be false by default") { Space.new.public.should be_falsey }
    it("should be true if set to") { Space.new(:public => true).public.should be true }
    it("should be false by default") { Space.new.disabled.should be_falsey }
    it("should be true if set to") { Space.new(:disabled => true).disabled.should be true }
    it("should be false by default") { Space.new.deleted.should be_falsey }
    it("should be true if set to") { Space.new(:deleted => true).deleted.should be true }
  end

  it { should have_many(:posts).dependent(:destroy) }
  it { should have_many(:events).dependent(:destroy) }
  it { should have_many(:news).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:destroy) }

  it { should have_one(:bigbluebutton_room).dependent(:destroy) }
  it { space.bigbluebutton_room.owner.should be(space) } # :as => :owner
  it { should accept_nested_attributes_for(:bigbluebutton_room) }

  it { should have_many(:permissions) }
  it { should have_and_belong_to_many(:users) }
  it { should have_and_belong_to_many(:admins) }
  it { should have_many(:join_requests) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should ensure_length_of(:name).is_at_least(3) }

  describe "#permalink" do
    it { should validate_uniqueness_of(:permalink).case_insensitive }
    it { should validate_presence_of(:permalink) }
    it { should ensure_length_of(:permalink).is_at_least(3) }
    it { should_not allow_value("123 321").for(:permalink) }
    it { should_not allow_value("").for(:permalink) }
    it { should_not allow_value("ab@c").for(:permalink) }
    it { should_not allow_value("ab#c").for(:permalink) }
    it { should_not allow_value("ab$c").for(:permalink) }
    it { should_not allow_value("ab%c").for(:permalink) }
    it { should_not allow_value("ábcd").for(:permalink) }
    it { should allow_value("---").for(:permalink) }
    it { should allow_value("-abc").for(:permalink) }
    it { should allow_value("abc-").for(:permalink) }
    it { should allow_value("_abc").for(:permalink) }
    it { should allow_value("abc_").for(:permalink) }
    it { should allow_value("abc").for(:permalink) }
    it { should allow_value("123").for(:permalink) }
    it { should allow_value("111").for(:permalink) }
    it { should allow_value("aaa").for(:permalink) }
    it { should allow_value("___").for(:permalink) }
    it { should allow_value("abc-123_d5").for(:permalink) }

    describe "validates uniqueness against User#username" do
      describe "on create" do
        context "with an enabled user" do
          let(:user) { FactoryGirl.create(:user) }
          subject { FactoryGirl.build(:space, :permalink => user.username) }
          it { should_not be_valid }
        end

        context "with a disabled user" do
          let(:disabled_user) { FactoryGirl.create(:user, :disabled => true) }
          subject { FactoryGirl.build(:space, :permalink => disabled_user.username) }
          it { should_not be_valid }
        end
      end

      describe "on update" do
        context "with an enabled user" do
          let(:user) { FactoryGirl.create(:user) }
          let(:space) { FactoryGirl.create(:space) }
          before(:each) {
            space.permalink = user.username
          }
          it { space.should_not be_valid }
        end

        context "with a disabled user" do
          let(:disabled_user) { FactoryGirl.create(:user, :disabled => true) }
          let(:space) { FactoryGirl.create(:space) }
          before(:each) {
            space.permalink = disabled_user.username
          }
          it { space.should_not be_valid }
        end
      end
    end
  end

  it "#check_errors_on_bigbluebutton_room"

  it { should respond_to(:invitation_ids) }
  it { should respond_to(:"invitation_ids=") }

  it { should respond_to(:invitation_mails) }
  it { should respond_to(:"invitation_mails=") }

  it { should respond_to(:invite_msg) }
  it { should respond_to(:"invite_msg=") }

  it { should respond_to(:inviter_id) }
  it { should respond_to(:"inviter_id=") }

  it { should respond_to(:invitations_role_id) }
  it { should respond_to(:"invitations_role_id=") }

  it { should respond_to(:crop_x) }
  it { should respond_to(:"crop_x=") }
  it { should respond_to(:crop_y) }
  it { should respond_to(:"crop_y=") }
  it { should respond_to(:crop_w) }
  it { should respond_to(:"crop_w=") }
  it { should respond_to(:crop_h) }
  it { should respond_to(:"crop_h=") }
  it { should respond_to(:logo_image) }

  describe "default_scope :disabled => false" do
    before {
      @s1 = FactoryGirl.create(:space, :disabled => false)
      @s2 = FactoryGirl.create(:space, :disabled => false)
      @s3 = FactoryGirl.create(:space, :disabled => true)
    }

    it { Space.count.should be 2 }
    it { Space.all.should include(@s1) }
    it { Space.all.should include(@s2) }
    it { Space.all.should_not include(@s3) }

    it { Space.with_disabled.count.should be 3 }
    it { Space.with_disabled.should include(@s1) }
    it { Space.with_disabled.should include(@s2) }
    it { Space.with_disabled.should include(@s3) }
  end

  describe ".public_spaces" do
    before {
      @public1 = FactoryGirl.create(:public_space)
      @public2 = FactoryGirl.create(:public_space)
      another = FactoryGirl.create(:private_space)
    }
    it { Space.public_spaces.length.should be(2) }
    it { Space.public_spaces.should include(@public1) }
    it { Space.public_spaces.should include(@public2) }
  end


  describe ".logo_image" do
    let!(:logo) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/files/test-logo.png'))) }
    let!(:crop_params) { {:crop_x => 0, :crop_y => 0, :crop_w => 10, :crop_h => 10} }

    context "uploader properties" do
      let(:space) { Space.new }
      let!(:store_dir) { File.join(Rails.root, 'spec/support/uploads/space/logo_image') }

      it { space.logo_image.filename.should_not be_present }
      it { space.logo_image.extension_white_list.should eq(["jpg", "jpeg", "png", "svg", "tif", "gif"]) }
      it { space.logo_image.versions.count.should eq(5) }
      it { space.logo_image.store_dir.should eq("#{store_dir}/#{space.id}") }
      it { space.logo_image.versions.map{|v| v[0]}.should eq([:large, :logo32, :logo84x64, :logo128, :logo168x128]) }
    end

    context "crop_logo" do
      context "is called after_create" do
        let(:space) { Space.new(space_attr) }

        context "with valid params" do
          let(:space_attr) { FactoryGirl.attributes_for(:space, :logo_image => logo).merge(crop_params) }

          before do
            space.logo_image.should_receive(:recreate_versions!)
            space.save!
          end

          it { space.logo_image.should be_present }
        end

        context "without file but valid crop params" do
          let(:space_attr) { FactoryGirl.attributes_for(:space, :logo_image => nil).merge(crop_params) }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.save!
          end

          it { space.logo_image.should_not be_present }
        end

        context "with file but invalid crop params" do
          let(:space_attr) { FactoryGirl.attributes_for(:space, :logo_image => logo) }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.save!
          end

          it { space.logo_image.should be_present }
        end
      end

      context "is called after_update" do
        let(:space) { FactoryGirl.create(:space) }

        context "with valid params" do
          let(:space_attr) { {:logo_image => logo}.merge(crop_params) }

          before do
            space.logo_image.should_receive(:recreate_versions!)
            space.update_attributes(space_attr)
          end

          it { space.logo_image.should be_present }
        end

        context "without file but valid crop params" do
          let(:space_attr) { {:logo_image => nil}.merge(crop_params) }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.update_attributes(space_attr)
          end

          it { space.logo_image.should_not be_present }
        end

        context "with file but invalid crop params" do
          let(:space_attr) { {:logo_image => logo} }

          before(:each) do
            space.logo_image.should_not_receive(:recreate_versions!)
            space.update_attributes(space_attr)
          end

          it { space.logo_image.should be_present }
        end
      end
    end

  end

  describe "::USER_ROLES" do
    it { Space::USER_ROLES.length.should be(2) }
    it { Space::USER_ROLES.should include("Admin") }
    it { Space::USER_ROLES.should include("User") }
  end

  describe "#upcoming_events" do
    context "returns the n upcoming events" do
      before {
        e1 = FactoryGirl.create(:event, :time_zone => Time.zone.name, :owner => space,
          :start_on => Time.zone.now - 5.hours, :end_on => Time.zone.now - 4.hours)
        e2 = FactoryGirl.create(:event, :owner => space, :time_zone => e1.time_zone,
          :start_on => Time.zone.now + 2.hour, :end_on => Time.zone.now + 3.hours)
        e3 = FactoryGirl.create(:event, :owner => space, :time_zone => e1.time_zone,
          :start_on => Time.zone.now + 3.hour, :end_on => Time.zone.now + 4.hours)
        e4 = FactoryGirl.create(:event, :owner => space, :time_zone => e1.time_zone,
          :start_on => Time.zone.now + 1.hour, :end_on => Time.zone.now + 2.hours)
        @expected = [e4, e2, e3]
      }
      it { space.upcoming_events(3).should eq(@expected) }
    end

    context "defaults to 5 events" do
      before {
        6.times { FactoryGirl.create(:event, :owner => space, :time_zone => Time.zone.name, :start_on => Time.zone.now + 1.hour, :end_on => Time.zone.now + 2.hours) }
      }
      it { space.upcoming_events.length.should be(5) }
    end
  end

  describe "#add_member!" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:user_role) { Role.find_by(:name => 'User') }
    let!(:admin_role) { Role.find_by(:name => 'Admin') }

    context "adds the user as a member with the selected role" do
      before {
        expect {
          if selected_role
            space.add_member!(user, selected_role)
          else
            space.add_member!(user)
          end
        }.to change(space.users, :count).by(1)
      }

      context 'with role User' do
        let(:selected_role) { 'User' }

        it { space.users include(user) }
        it { space.permissions.last.user.should eq(user) }
        it { space.permissions.last.role.should eq(user_role) }
        it { space.role_for?(user, :name => 'User').should be true }
        it { space.role_for?(user, :name => 'Admin').should be false }
      end

      context 'with role Admin' do
        let(:selected_role) { 'Admin' }

        it { space.users include(user) }
        it { space.permissions.last.user.should eq(user) }
        it { space.permissions.last.role.should eq(admin_role) }
        it { space.role_for?(user, :name => 'User').should be false }
        it { space.role_for?(user, :name => 'Admin').should be true }
      end

      context "defaults the role to 'User'" do
        let(:selected_role) { nil }

        it { space.users include(user) }
        it { space.permissions.last.user.should eq(user) }
        it { space.permissions.last.role.should eq(user_role) }
        it { space.role_for?(user, :name => 'User').should be true }
        it { space.role_for?(user, :name => 'Admin').should be false }
      end

    end

    context "doesn't add the user if he's already a member" do
      let(:permission) { Permission.create(:user => user, :role => user_role, :subject => space) }

      before {
        permission
        expect {
          space.add_member!(user)
        }.to raise_error(ActiveRecord::RecordInvalid)
      }

      it { space.users include(user) }
      it { space.permissions.last.user.should eq(user) }
    end

  end

  it "new_activity"

  describe ".with_disabled" do
    let(:space1) { FactoryGirl.create(:space, :disabled => true) }
    let(:space2) { FactoryGirl.create(:space, :disabled => false) }

    context "finds spaces even if disabled" do
      subject { Space.with_disabled.all }
      it { should include(space1) }
      it { should include(space2) }
    end

    context "returns a Relation object" do
      it { Space.with_disabled.should be_kind_of(ActiveRecord::Relation) }
    end
  end

  describe "#create_webconf_room" do

    it "is called when the space is created" do
      space = FactoryGirl.create(:space)
      space.bigbluebutton_room.should_not be_nil
      space.bigbluebutton_room.should be_kind_of(BigbluebuttonRoom)
    end

    context "creates #bigbluebutton_room" do

      it "with the space as owner" do
        space.bigbluebutton_room.owner.should be(space)
      end

      it "with param and name equal the space's permalink" do
        space.bigbluebutton_room.param.should eql(space.permalink)
        space.bigbluebutton_room.name.should eql(space.name)
      end

      it "with the default logout url" do
        space.bigbluebutton_room.logout_url.should eql("/feedback/webconf/")
      end

      it "as public is the space is public" do
        space = FactoryGirl.create(:space, :public => true)
        space.bigbluebutton_room.private.should be false
      end

      it "as private is the space is private" do
        space = FactoryGirl.create(:space, :public => false)
        space.bigbluebutton_room.private.should be true
      end

      skip "with the server as the first server existent"
    end
  end

  describe "#update_webconf_room" do
    context "updates the webconf room" do
      let(:space) { FactoryGirl.create(:space, :name => "Old Name", :public => true) }
      before(:each) { space.update_attributes(:name => "New Name", :public => false) }
      it { space.bigbluebutton_room.param.should be(space.permalink) }
      it { space.bigbluebutton_room.name.should be(space.name) }
      it { space.bigbluebutton_room.private.should be(true) }
    end

    it "updates to public when the space is made public" do
      space.update_attribute(:public, true)
      space.bigbluebutton_room.private.should be false
    end

    it "updates to private when the space is made public" do
      space.update_attribute(:public, false)
      space.bigbluebutton_room.private.should be true
    end
  end

  describe "user associations" do
    before {
      @users = []
      0.upto(3) { @users << FactoryGirl.create(:user) }
      space.add_member!(@users[0], "Admin")
      space.add_member!(@users[1], "Admin")
      space.add_member!(@users[2], "User")
    }

    describe "#permissions" do
      it { space.permissions.klass == Permission }
      it { space.permissions.length.should be(3) }
      it { space.permissions.should include(*Permission.where(:user_id => @users)) }
    end

    describe "#admins" do
      context "returns the admins of the space" do
        it { space.admins.klass == User }
        it { space.admins.length.should be(2) }
        it { space.admins.should include(@users[0]) }
        it { space.admins.should include(@users[1]) }
      end
    end

    describe "#users" do
      context "returns the users of the space" do
        it { space.users.klass == User }
        it { space.users.length.should be(3) }
        it { space.users.should include(@users[0]) }
        it { space.users.should include(@users[1]) }
        it { space.users.should include(@users[2]) }
      end
    end

  end

  describe "join requests" do
    before {
      @jr = [
        FactoryGirl.create(:join_request, :group => space, :request_type => 'request'),
        FactoryGirl.create(:join_request, :group => space, :request_type => 'request'),
        FactoryGirl.create(:join_request, :group => space, :request_type => 'invite')
      ]
      @invitations = [@jr[2]]
      @requests = [@jr[0], @jr[1]]
    }

    describe "#join_requests" do
      it { space.join_requests.should include(*@jr) }
      it { space.join_requests.length.should be(3) }
      it { space.join_requests.should include(*[@invitations, @requests].flatten) }
    end

    describe "#pending_join_requests" do
      it { space.pending_join_requests.klass == JoinRequest }
      it { space.pending_join_requests.length.should be(2) }
      it { space.pending_join_requests.should include(*@requests) }
    end

    describe "#pending_invitations" do
      it { space.pending_invitations.klass == JoinRequest }
      it { space.pending_invitations.length.should be(1) }
      it { space.pending_invitations.should include(*@invitations) }
    end

    describe "#pending_join_request_for(?)" do
      let(:user) { @requests.first.candidate }
      let(:other_user) { FactoryGirl.create(:user) }

      it { space.pending_join_request_for(user).should eq(@requests.first) }
      it { space.pending_join_request_for(other_user).should be_blank }
      it { space.pending_join_request_for?(user).should be true }
      it { space.pending_join_request_for?(other_user).should be false }
    end

    describe "#pending_invitation_for(?)" do
      let(:user) { @invitations.first.candidate }
      let(:other_user) { FactoryGirl.create(:user) }

      it { space.pending_invitation_for(user).should eq(@invitations.first) }
      it { space.pending_invitation_for(other_user).should be_blank }
      it { space.pending_invitation_for?(user).should be true }
      it { space.pending_invitation_for?(other_user).should be false }
    end

  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:leave, :enable, :webconference, :select, :disable, :update_logo,
      :user_permissions, :edit_recording, :webconference_options, :recordings])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }

        context "he is not a member of" do
          it { should be_able_to_do_anything_to(target) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should be_able_to_do_anything_to(target) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should be_able_to_do_anything_to(target) }
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should be_able_to_do_anything_to(target) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should be_able_to_do_anything_to(target) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should be_able_to_do_anything_to(target) }
          end
        end
      end
    end

    context "a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :recordings, :create, :select]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :recordings, :create, :select, :leave, :edit,
              :update, :update_logo, :disable, :user_permissions, :edit_recording, :webconference_options]) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :recordings, :create, :select, :leave]) }
          end
        end
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:create, :select]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :recordings, :create, :select, :leave, :edit,
              :update, :update_logo, :disable, :user_permissions, :edit_recording, :webconference_options]) }
          end

          context "with the role 'User'" do
            before { target.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :recordings, :create, :select, :leave]) }
          end
        end
      end
    end

    context "an anonymous user", :user => "anonymous" do
      let(:user) { User.new }

      context "in a public space" do
        let(:target) { FactoryGirl.create(:public_space) }
        it { should_not be_able_to_do_anything_to(target).except([:read, :webconference, :recordings, :select]) }
      end

      context "in a private space" do
        let(:target) { FactoryGirl.create(:private_space) }
        it { should_not be_able_to_do_anything_to(target).except([:select]) }
      end
    end

  end
end
