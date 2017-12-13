# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe User do

  before(:each, :events => true) do
    Site.current.update_attributes(:events_enabled => true)
  end

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:user).should be_valid
  end

  describe "initializes with default values" do
    it { User.new.created_by.should be(nil) }

    context "#can_record" do
      before {
        @can_record_before = Rails.application.config.can_record_default
      }
      after {
        Rails.application.config.can_record_default = @can_record_before
      }

      context "when the default is set to false in the application" do
        before { Rails.application.config.can_record_default = false }
        it { User.new.can_record.should be(false) }
      end

      context "when the default is set to true in the application" do
        before { Rails.application.config.can_record_default = true }
        it { User.new.can_record.should be(true) }
      end

      context "doesn't change if there's already a value set" do
        let(:user1) { FactoryGirl.create(:user, can_record: false) }
        let(:user2) { FactoryGirl.create(:user, can_record: true) }
        it { User.find(user1.id).can_record.should be(false) }
        it { User.find(user2.id).can_record.should be(true) }
      end
    end
  end

  it { should have_one(:profile).dependent(:destroy) }
  it { should have_one(:bigbluebutton_room).dependent(:destroy) }
  it { should have_and_belong_to_many(:spaces) }
  it { should have_many(:permissions) }
  it { should have_many(:posts) }
  it { should have_many(:emails) }
  it { should have_one(:ldap_token).dependent(:destroy) }
  it { should have_one(:shib_token).dependent(:destroy) }
  it { should have_one(:certificate_token).dependent(:destroy) }

  it { should accept_nested_attributes_for(:profile) }

  describe 'model validations' do
    subject { FactoryGirl.create(:user) } # Trying to solve the bug 2 lines below

    it { should validate_presence_of(:email) }

    # Not working because of conflict with devise, see https://github.com/thoughtbot/shoulda-matchers/issues/836
    skip { should validate_uniqueness_of(:email) }

    # Needs a matcher
    # skip { should validate_email }
  end

  # Make sure it's being tested in the controller
  # [ :email, :password, :password_confirmation,
  #   :remember_me, :login, :username, :approved ].each do |attribute|
  #   it { should allow_mass_assignment_of(attribute) }
  # end

  describe ".search_by_terms" do
    let(:users) {[
      FactoryGirl.create(:user, username: 'steve', email: 'steve@email.com', created_at: Time.now),
      FactoryGirl.create(:user, username: 'steve-hairis', email: 'steve-hairis@email.com', created_at: Time.now + 1.second),
      FactoryGirl.create(:user, username: 'ismael-esteves', email: 'ismael-esteves@email.com', created_at: Time.now + 2.second)
    ]}
    let(:include_private) { false }
    let(:subject) { User.search_by_terms(terms, include_private) }

    before {
      users[0].profile.update_attribute(:full_name, 'Steve and Will Soon')
      users[1].profile.update_attribute(:full_name, 'Steve Hair is')
      users[2].profile.update_attribute(:full_name, 'Ismael Esteves')
    }

    context '1 term finds something' do
      let(:terms) { ['steve'] }

      it { should include(users[0], users[1], users[2]) }
      it { subject.count.should be(3) }
    end

    context 'composite term finds something' do
      let(:terms) { ['steve hair'] }

      it { should include(users[1]) }
      it { subject.count.should be(1) }
    end

    context '2 terms find something' do
      let(:terms) { ['esteves', 'hair'] }
      it { should include(users[1], users[2]) }
      it { subject.count.should be(2) }
    end

    context '1 term finds nothing 1 term finds something' do
      let(:terms) { ['mikael', 'esteves'] }
      it { should include(users[2]) }
      it { subject.count.should be(1) }
    end

    context '1 term finds nothing' do
      let(:terms) { ['mikael'] }
      it { subject.count.should eq(0) }
    end

    context 'multiple terms find nothing' do
      let(:terms) { ['Maninho', 'das', 'Qebrada'] }
      it { subject.count.should eq(0) }
    end

    context "returns a Relation object" do
      let(:terms) { [''] }
      it { subject.should be_kind_of(ActiveRecord::Relation) }
    end

    context "accepts a string as parameter" do
      let(:terms) { 'steve' }
      it { should include(users[0], users[1], users[2]) }
      it { subject.count.should be(3) }
    end

    context "is chainable" do
      let!(:user1) { FactoryGirl.create(:user, can_record: true, username: "abc") }
      let!(:user2) { FactoryGirl.create(:user, can_record: true, username: "def") }
      let!(:user3) { FactoryGirl.create(:superuser, can_record: true, username: "abc-2") }
      let!(:user4) { FactoryGirl.create(:superuser, can_record: true, username: "def-2") }
      let!(:user5) { FactoryGirl.create(:superuser, can_record: false, username: "abc-3") }
      subject { User.superusers.where(can_record: true).search_by_terms('abc') }
      it { subject.should include(user3) }
      it { subject.should_not include(user1) }
      it { subject.should_not include(user2) }
      it { subject.should_not include(user4) }
      it { subject.should_not include(user5) }
    end

    context "searches by email if include_private is true" do
      let(:include_private) { true }
      let(:terms) { 'steve-hairis@email.com' }
      it { subject.count.should be(1) }
      it { should include(users[1]) }
    end

    context "doesn't search by email if include_private is false" do
      let(:terms) { 'steve-hairis@email.com' }
      it { subject.count.should be(0) }
    end
  end

  describe ".search_order" do
    it "orders by full name"
  end

  describe ".superusers" do
    context "returns only the superusers" do
      let!(:superuser1) { FactoryGirl.create(:superuser) }
      let!(:superuser2) { FactoryGirl.create(:superuser) }
      let!(:user1) { FactoryGirl.create(:user) }
      let!(:user2) { FactoryGirl.create(:user) }
      let(:subject) { User.superusers }

      it { subject.count.should eql(3) } # plus the default admin
      it { subject.should include(superuser1) }
      it { subject.should include(superuser2) }
    end

    context "returns only normal users if the param is false" do
      let!(:superuser1) { FactoryGirl.create(:superuser) }
      let!(:superuser2) { FactoryGirl.create(:superuser) }
      let!(:user1) { FactoryGirl.create(:user) }
      let!(:user2) { FactoryGirl.create(:user) }
      let(:subject) { User.superusers(false) }

      it { subject.count.should eql(2) }
      it { subject.should include(user1) }
      it { subject.should include(user2) }
    end

    context "returns a Relation object" do
      let(:subject) { User.superusers }
      it { subject.should be_kind_of(ActiveRecord::Relation) }
    end
  end

  describe ".with_auth" do
    it "filters by local authentication"
    it "filters by shibboleth authentication"
    it "filters by LDAP authentication"
    it "filters by certificate authentication"
    it "uses AND as the default connector"
    it "uses the connector chosen"
    it "doesn't filter anything if no auth method was selected"
    it "doesn't clean up previous queries if no auth method was selected"
  end

  describe "#profile" do
    let(:user) { FactoryGirl.create(:user) }

    it "is created when the user is created" do
      user.profile.should_not be_nil
      user.profile.should be_kind_of(Profile)
    end
  end

  describe "#bigbluebutton_room" do
    let(:user) { FactoryGirl.create(:user) }
    it { should have_one(:bigbluebutton_room).dependent(:destroy) }
    it { should accept_nested_attributes_for(:bigbluebutton_room) }

    it "is created when the user is created" do
      user.bigbluebutton_room.should_not be_nil
      user.bigbluebutton_room.should be_kind_of(BigbluebuttonRoom)
    end

    it "has the user as owner" do
      user.bigbluebutton_room.owner.should eq(user)
    end

    it "has slug and name equal the user's username" do
      user.bigbluebutton_room.slug.should eql(user.username)
      user.bigbluebutton_room.name.should eql(user.name)
    end

    it "has the default logout url" do
      user.bigbluebutton_room.logout_url.should eql("/feedback/webconf/")
    end

    it "has random passwords set" do
      user.bigbluebutton_room.attendee_key.should_not be_blank
      user.bigbluebutton_room.attendee_key.length.should be(8)
      user.bigbluebutton_room.moderator_key.should_not be_blank
      user.bigbluebutton_room.moderator_key.length.should be(16)
    end

    skip "has the server as the first server existent"
  end

  describe "#username" do
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_length_of(:username).is_at_least(1) }
    it { should_not allow_value("123 321").for(:username) }
    it { should_not allow_value("").for(:username) }
    it { should_not allow_value("ab@c").for(:username) }
    it { should_not allow_value("ab#c").for(:username) }
    it { should_not allow_value("ab$c").for(:username) }
    it { should_not allow_value("ab%c").for(:username) }
    it { should_not allow_value("ábcd").for(:username) }
    it { should allow_value("-").for(:username) }
    it { should allow_value("-abc").for(:username) }
    it { should allow_value("abc-").for(:username) }
    it { should allow_value("_abc").for(:username) }
    it { should allow_value("abc_").for(:username) }
    it { should allow_value("abc").for(:username) }
    it { should allow_value("123").for(:username) }
    it { should allow_value("1").for(:username) }
    it { should allow_value("a").for(:username) }
    it { should allow_value("_").for(:username) }
    it { should allow_value("abc-123_d5").for(:username) }
  end

  %w[username slug].each do |method_name|
    describe "##{method_name}" do
      shared_examples "invalid user with username not unique" do
        it { subject.should_not be_valid }
        it {
          subject.save.should be(false)
          subject.errors.should have_key(:username)
          subject.errors.messages[:username].should include(message)
        }
      end

      describe "blocks reserved words" do
        let(:message) { "has already been taken" }
        file = File.join(::Rails.root, "config", "reserved_words.yml")
        words = YAML.load_file(file)['words']

        describe "on create" do
          words.each do |word|
            context "word: #{word}" do
              subject { FactoryGirl.build(:user, "#{method_name}": word) }
              include_examples "invalid user with username not unique"
            end
          end
        end

        describe "on update" do
          words.each do |word|
            context "word: #{word}" do
              let(:subject) { FactoryGirl.create(:user) }
              before(:each) {
                subject.send("#{method_name}=", word)
              }
              include_examples "invalid user with username not unique"
            end
          end
        end
      end

      describe "validates uniqueness against Space#slug" do
        let(:message) { "has already been taken" }

        describe "on create" do
          context "with an enabled space" do
            let(:space) { FactoryGirl.create(:space) }
            subject { FactoryGirl.build(:user, "#{method_name}": space.slug) }
            include_examples "invalid user with username not unique"
          end

          context "with a disabled space" do
            let(:disabled_space) { FactoryGirl.create(:space, disabled: true) }
            subject { FactoryGirl.build(:user, "#{method_name}": disabled_space.slug) }
            include_examples "invalid user with username not unique"
          end

          context "uses case-insensitive comparisons" do
            let!(:space) { FactoryGirl.create(:space, slug: "My-Weird-Name") }
            subject { FactoryGirl.build(:user, "#{method_name}": "mY-weiRD-NAMe") }
            include_examples "invalid user with username not unique"
          end
        end

        describe "on update" do
          context "with an enabled space" do
            let(:subject) { FactoryGirl.create(:user) }
            let(:space) { FactoryGirl.create(:space) }
            before(:each) {
              subject.send("#{method_name}=", space.slug)
            }
            include_examples "invalid user with username not unique"
          end

          context "with a disabled space" do
            let(:subject) { FactoryGirl.create(:user) }
            let(:disabled_space) { FactoryGirl.create(:space, :disabled => true) }
            before(:each) {
              subject.send("#{method_name}=", disabled_space.slug)
            }
            include_examples "invalid user with username not unique"
          end

          context "uses case-insensitive comparisons" do
            let(:subject) { FactoryGirl.create(:user) }
            let!(:space) { FactoryGirl.create(:space, slug: "My-Weird-Name") }
            before(:each) {
              subject.send("#{method_name}=", "mY-weiRD-NAMe")
            }
            include_examples "invalid user with username not unique"
          end
        end
      end

      describe "validates uniqueness against User##{method_name}" do
        let(:message) { "has already been taken" }

        describe "on create" do
          context "with an enabled user" do
            let(:user) { FactoryGirl.create(:user) }
            subject { FactoryGirl.build(:user, "#{method_name}": user.username) }
            include_examples "invalid user with username not unique"
          end

          context "with a disabled user" do
            let(:disabled_user) { FactoryGirl.create(:user, disabled: true) }
            subject { FactoryGirl.build(:user, "#{method_name}": disabled_user.username) }
            include_examples "invalid user with username not unique"
          end

          context "uses case-insensitive comparisons" do
            let!(:user) { FactoryGirl.create(:user, "#{method_name}": "My-Weird-Name") }
            subject { FactoryGirl.build(:user, "#{method_name}": "mY-weiRD-NAMe") }
            include_examples "invalid user with username not unique"
          end
        end

        describe "on update" do
          context "with an enabled space" do
            let(:subject) { FactoryGirl.create(:user) }
            let(:other_user) { FactoryGirl.create(:user) }
            before(:each) {
              subject.send("#{method_name}=", other_user.username)
            }
            include_examples "invalid user with username not unique"
          end

          context "with a disabled space" do
            let(:subject) { FactoryGirl.create(:user) }
            let(:disabled_user) { FactoryGirl.create(:user, :disabled => true) }
            before(:each) {
              subject.send("#{method_name}=", disabled_user.username)
            }
            include_examples "invalid user with username not unique"
          end

          context "uses case-insensitive comparisons" do
            let(:subject) { FactoryGirl.create(:user) }
            let!(:other_user) { FactoryGirl.create(:user, username: "My-Weird-Name") }
            before(:each) {
              subject.send("#{method_name}=", "mY-weiRD-NAMe")
            }
            include_examples "invalid user with username not unique"
          end
        end
      end

      context "validates against webconf room params" do
        let(:message) { "has already been taken" }

        describe "on create" do
          context "with an exact match" do
            let(:room) { FactoryGirl.create(:bigbluebutton_room) }
            subject { FactoryGirl.build(:user, "#{method_name}": room.slug) }
            include_examples "invalid user with username not unique"
          end

          context "uses case-insensitive comparisons" do
            let!(:room) { FactoryGirl.create(:bigbluebutton_room, slug: "My-Weird-Name") }
            subject { FactoryGirl.build(:user, "#{method_name}": "mY-weiRD-NAMe") }
            include_examples "invalid user with username not unique"
          end
        end

        describe "on update" do
          context "with an exact match" do
            let(:subject) { FactoryGirl.create(:user) }
            let(:other_room) { FactoryGirl.create(:bigbluebutton_room) }
            before(:each) {
              subject.send("#{method_name}=", other_room.slug)
            }
            include_examples "invalid user with username not unique"
          end

          context "uses case-insensitive comparisons" do
            let(:subject) { FactoryGirl.create(:user) }
            let!(:other_room) { FactoryGirl.create(:bigbluebutton_room, slug: "My-Weird-Name") }
            before(:each) {
              subject.send("#{method_name}=", "mY-weiRD-NAMe")
            }
            include_examples "invalid user with username not unique"
          end

          context "doesn't validate against its own room" do
            let!(:user) { FactoryGirl.create(:user) }
            it { user.update_attributes("#{method_name}": user.send(method_name)).should be(true) }
          end
        end
      end

      describe "generates a unique username when creating without setting a username" do

        context "conflicting with another user" do
          let(:another_user) { FactoryGirl.create(:user, "#{method_name}": nil) }
          let(:user) {
            FactoryGirl.create(:user, "#{method_name}": nil, profile_attributes: { full_name: another_user.name })
          }
          it { user.send(method_name).should eql(another_user.username + "-2") }
        end

        context "conflicting with a disabled user" do
          let(:another_user) { FactoryGirl.create(:user, "#{method_name}": nil, disabled: true) }
          let(:user) {
            FactoryGirl.create(:user, "#{method_name}": nil, profile_attributes: { full_name: another_user.name })
          }
          it { user.send(method_name).should eql(another_user.send(method_name) + "-2") }
        end

        context "conflicting with a space" do
          let(:space) { FactoryGirl.create(:space, slug: nil) }
          let(:user) {
            FactoryGirl.create(:user, "#{method_name}": nil, profile_attributes: { full_name: space.name })
          }
          it { user.send(method_name).should eql(space.slug + "-2") }
        end

        context "conflicting with a disabled space" do
          let(:space) { FactoryGirl.create(:space, slug: nil, disabled: false) }
          let(:user) {
            FactoryGirl.create(:user, "#{method_name}": nil, profile_attributes: { full_name: space.name })
          }
          it { user.send(method_name).should eql(space.slug + "-2") }
        end

        context "conflicting with a room" do
          let!(:another_user) {
            u = FactoryGirl.create(:user)
            u.bigbluebutton_room.update_attributes(slug: 'anything')
            u
          }
          let(:user) {
            FactoryGirl.create(:user, "#{method_name}": nil, profile_attributes: { full_name: 'anything' })
          }
          it { user.send(method_name).should eql("anything-2") }
        end

        context "conflicting with a blacklisted word" do
          let(:user) {
            FactoryGirl.create(:user, "#{method_name}": nil, profile_attributes: { full_name: 'Spaces' })
          }
          it { user.send(method_name).should eql("spaces-2") }
        end
      end
    end
  end

  describe "on update" do
    let(:user) { FactoryGirl.create(:user) }

    it("calls #update_webconf_room") {
      user.should_receive(:update_webconf_room)
      user.update_attributes(slug: "new-slug")
    }
  end

  describe "on create" do

    describe "#automatically_approve_if_needed" do
      context "if #require_registration_approval is not set in the current site" do
        before { Site.current.update_attributes(require_registration_approval: false) }

        context "automatically approves the user" do
          before(:each) { @user = FactoryGirl.create(:user, approved: false) }
          it { @user.should be_approved }
        end
      end

      context "if #require_registration_approval is set in the current site" do
        before { Site.current.update_attributes(require_registration_approval: true) }

        context "doesn't approve the user" do
          let(:user) { FactoryGirl.create(:user, approved: false) }
          it { user.should_not be_approved }
        end
      end
    end

    describe 'user approval notifications' do
      let(:admin) { User.superusers.first }

      context 'dont send notifications if the site doesnt require approval' do
        before {
          Site.current.update_attributes(require_registration_approval: false)
          @user = FactoryGirl.create(:user, approved: false)
        }

        it { AdminMailer.should have_queue_size_of(0) }
        it { AdminMailer.should_not have_queued(:new_user_waiting_for_approval, admin.id, @user.id) }
      end

      context 'send notifications if site requires approval' do
        before { Site.current.update_attributes(require_registration_approval: true) }

        context 'dont send notifications if the user is created with approved: true' do
          before { @user = FactoryGirl.build(:user, approved: true) }

          it { AdminMailer.should have_queue_size_of(0) }
          it { AdminMailer.should_not have_queued(:new_user_waiting_for_approval, admin.id, @user.id) }
        end
      end
    end
  end

  describe "on destroy" do
    let(:user) { FactoryGirl.create(:user) }

    context 'removes permissions related to spaces' do
      let(:space) { FactoryGirl.create(:space) }
      before { space.add_member!(user) }
      it {
        expect { user.destroy }.to change(Permission, :count).by(-1)
        Permission.where(subject: space, user: user).should be_empty
      }
    end

    context 'removes permissions related to events' do
      let(:event) { FactoryGirl.create(:event) }
      before { Permission.create(subject: event, user: user, role: Role.find_by_name('Organizer')) }
      it {
        expect { user.destroy }.to change(Permission, :count).by(-1)
        Permission.where(subject: event, user: user).should be_empty
      }
    end

    context "removes permissions related to the site" do
      before { Permission.create(subject: Site.current, user: user, role: Role.find_by_name('Global Admin')) }
      it {
        expect { user.destroy }.to change(Permission, :count).by(-1)
        Permission.where(subject: Site.current, user: user).should be_empty
      }
    end

    context 'removes pending join requests' do
      let(:space) { FactoryGirl.create(:space) }
      let(:space2) { FactoryGirl.create(:space) }
      let!(:processed_join_request) { FactoryGirl.create(:join_request_invite, candidate: user, group: space, processed_at: Time.now - 2.days) }
      let!(:space_join_request) { FactoryGirl.create(:join_request_invite, candidate: user, group: space, processed_at: nil) }
      let!(:space_join_request_invite) { FactoryGirl.create(:join_request_invite, candidate: user, group: space2, processed_at: nil) }
      it { expect { user.destroy }.to change(JoinRequest, :count).by(-2) }
    end

    context "doesn't remove the invitations the user sent" do
      let!(:join_request_invite) { FactoryGirl.create(:join_request_invite, introducer: user) }
      it { expect { user.destroy }.not_to change(JoinRequest, :count) }
    end

    context "when the user is admin of a space" do
      let(:space) { FactoryGirl.create(:space) }

      context "and is the last admin left" do
        before(:each) do
          space.add_member!(user, 'Admin')
          user.destroy
        end

        it { space.reload.disabled.should be(true) }
      end

      context "and is the last admin left and there are other members" do
        let(:user2) { FactoryGirl.create(:user) }
        before(:each) do
          space.add_member!(user, 'Admin')
          space.add_member!(user2, 'User')
          user.destroy
        end

        it { space.reload.disabled.should be(true) }
      end

      context "and isn't the last admin left" do
        let(:user2) { FactoryGirl.create(:user) }
        before(:each) do
          space.add_member!(user, 'Admin')
          space.add_member!(user2, 'Admin')
          user.destroy
        end

        it { space.disabled.should be(false) }
      end

      context "doesn't break if there are disabled spaces" do
        let(:space2) { FactoryGirl.create(:space) }
        before(:each) do
          space.add_member!(user, 'Admin')
          space2.add_member!(user, 'Admin')
          space2.disable
          user.destroy
        end

        it { space.reload.disabled.should be(true) }
      end
    end
  end

  describe "#events", :events => true do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }
    let(:another_one) { FactoryGirl.create(:user) }

    before(:each) do
      @events = [
      FactoryGirl.create(:event, :owner => user),
      FactoryGirl.create(:event, :owner => user),
      FactoryGirl.create(:event, :owner => other_user)
      ]
    end

    it { user.events.size.should eql(2) }
    it { user.events.should include(@events[0], @events[1]) }
    it { user.events.should_not include(@events[2]) }
    it { other_user.events.should include(@events[2]) }
    it { another_one.events.should be_empty }
  end

  skip "#has_events_in_this_space?"

  describe "#accessible_rooms" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:user_room) { FactoryGirl.create(:bigbluebutton_room, :owner => user) }
    let(:private_space_member) { FactoryGirl.create(:space_with_associations, public: false) }
    let!(:private_space_not_member) { FactoryGirl.create(:space_with_associations, public: false) }
    let(:public_space_member) { FactoryGirl.create(:space_with_associations, public: true) }
    let!(:public_space_not_member) { FactoryGirl.create(:space_with_associations, public: true) }
    before do
      private_space_member.add_member!(user)
      public_space_member.add_member!(user)
    end

    subject { user.accessible_rooms }
    it { subject.should == subject.uniq }
    it { should include(user_room) }
    it { should include(private_space_member.bigbluebutton_room) }
    it { should include(public_space_member.bigbluebutton_room) }
    it { should include(public_space_not_member.bigbluebutton_room) }
    it { should_not include(private_space_not_member.bigbluebutton_room) }
  end

  describe "#anonymous" do
    subject { user.anonymous? }

    context "for a user in the database" do
      let(:user) { FactoryGirl.create(:user) }
      it { should be false }
    end

    context "for a user not in the database" do
      let(:user) { FactoryGirl.build(:user) }
      it { should be true }
    end
  end

  describe "#fellows" do
    context "returns the fellows of the current user" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @users = Helpers.create_fellows(2, space)
        # 2 no fellows
        2.times { FactoryGirl.create(:user) }
      end
      it { subject.length.should == 2 }
      it { should include(@users[0]) }
      it { should include(@users[1]) }
    end

    context "filters by name" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows("another") }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @fellows = Helpers.create_fellows(3, space)
        @fellows[0].profile.update_attribute(:full_name, "Yet Another User")
        @fellows[1].profile.update_attribute(:full_name, "Abc de Fgh")
        @fellows[2].profile.update_attribute(:full_name, "Marcos da Silva")
      end
      it { subject.length.should == 1 }
      it { should include(@fellows[0]) }
    end

    context "orders by name" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @users = Helpers.create_fellows(5, space)
        @users.sort!{ |x, y| x.name <=> y.name }
      end
      it { subject.length.should == 5 }
      it { should == @users }
    end

    context "don't return duplicates" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space1 = FactoryGirl.create(:space)
        space2 = FactoryGirl.create(:space)
        space1.add_member! user
        space2.add_member! user
        @fellow = FactoryGirl.create(:user)
        space1.add_member! @fellow
        space2.add_member! @fellow
      end
      it { subject.length.should == 1 }
      it { should include(@fellow) }
    end

    context "don't return the user himself" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        @users = Helpers.create_fellows(2, space)
      end
      it { subject.length.should == 2 }
      it { should include(@users[0]) }
      it { should include(@users[1]) }
      it { should_not include(user) }
    end

    context "limits the results" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows(nil, 3) }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        Helpers.create_fellows(10, space)
      end
      it { subject.length.should == 3 }
    end

    context "limits to 5 results by default" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        Helpers.create_fellows(10, space)
      end
      it { subject.length.should == 5 }
    end

    context "limits to a maximum of 50 results" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.fellows(nil, 51) }
      before do
        space = FactoryGirl.create(:space)
        space.add_member! user
        Helpers.create_fellows(60, space)
      end
      it { subject.length.should == 50 }
    end
  end

  describe "#private_fellows" do
    context "returns the private fellows of the current user" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.private_fellows }
      before do
        private_space = FactoryGirl.create(:space, :public => false)
        public_space = FactoryGirl.create(:space, :public => true)
        private_space.add_member! user
        public_space.add_member! user

        @users = Helpers.create_fellows(2, private_space)
        @users += Helpers.create_fellows(2, public_space)
        # 2 extra not fellows
        2.times { FactoryGirl.create(:user) }
      end
      it { subject.length.should == 2 }
      it { should include(@users[0], @users[1]) }
      it { should_not include(@users[2],@users[3]) }
    end

    context "orders by name" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.private_fellows }
      before do
        space = FactoryGirl.create(:space, :public => false)
        space.add_member! user
        @users = Helpers.create_fellows(5, space)
        @users.sort_by!{ |u| u.name }
      end
      it { subject.length.should == 5 }
      it { should == @users }
    end

    context "don't return duplicates" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.private_fellows }
      before do
        space1 = FactoryGirl.create(:private_space)
        space2 = FactoryGirl.create(:private_space)
        space1.add_member! user
        space2.add_member! user
        @fellow = FactoryGirl.create(:user)
        space1.add_member! @fellow
        space2.add_member! @fellow
      end
      it { subject.length.should == 1 }
      it { should include(@fellow) }
      it { should_not include(user) }
    end

    context "don't return the user himself" do
      let(:user) { FactoryGirl.create(:user) }
      subject { user.private_fellows }
      before do
        space = FactoryGirl.create(:private_space)
        space.add_member! user
        @users = Helpers.create_fellows(2, space)
      end
      it { subject.length.should == 2 }
      it { should include(@users[0]) }
      it { should include(@users[1]) }
      it { should_not include(user) }
    end
  end

  describe ".with_disabled" do
    context "finds users that are disabled" do
      let!(:user1) { FactoryGirl.create(:user, disabled: true) }
      let!(:user2) { FactoryGirl.create(:user, disabled: false) }
      subject { User.with_disabled }
      it { should be_include(user1) }
      it { should be_include(user2) }
    end

    context "returns a Relation object" do
      it { User.with_disabled.should be_kind_of(ActiveRecord::Relation) }
    end

    context "doesn't remove previous scopes from the query" do
      let!(:user1) { FactoryGirl.create(:user, disabled: true, can_record: true) }
      let!(:user2) { FactoryGirl.create(:user, disabled: true, can_record: false) }

      subject { User.where(can_record: true).with_disabled.all }
      it { should include(user1) }
      it { should_not include(user2) }
    end

    context "is chainable" do
      let!(:user1) { FactoryGirl.create(:user, can_record: true, username: "abc") }
      let!(:user2) { FactoryGirl.create(:user, can_record: true, username: "def") }
      let!(:user3) { FactoryGirl.create(:user, can_record: false, username: "abc-2") }
      let!(:user4) { FactoryGirl.create(:user, can_record: false, username: "def-2") }
      subject { User.where(can_record: true).with_disabled.where('users.slug LIKE ?', '%abc%') }
      it { subject.count.should eq(1) }
    end
  end

  describe "#approve!" do
    let(:user) { FactoryGirl.create(:unconfirmed_user, approved: false) }
    before {
      Site.current.update_attributes(require_registration_approval: true)
    }
    context "sets the user as approved" do
      before { user.approve! }
      it { user.approved.should be true }
    end

    context "confirms the user if it's not already confirmed" do
      let(:user) { FactoryGirl.create(:unconfirmed_user, approved: false) }
      before(:each) { user.approve! }
      it { user.should be_approved }
      it { user.should be_confirmed }
    end

    context "throws an exception if fails to update the user" do
      it {
        user.should_receive(:update_attributes) { throw Exception.new }
        expect { user.approve! }.to raise_error
      }
    end
  end

  describe "#disapprove!" do
    let(:user) { FactoryGirl.create(:user, :approved => true) }
    let(:superuser) { FactoryGirl.create(:superuser) }
    let(:params) {
      { :username => "any", :email => "any@jaloo.com", :approved => false, :password => "123456" }
    }

    context "sets the user as disapproved" do
      before { user.disapprove! }
      it { user.should_not be_approved }
    end

    context "throws an exception if fails to update the user" do
      it {
        user.should_receive(:update_attributes) { throw Exception.new }
        expect { user.disapprove! }.to raise_error
      }
    end
  end

  describe "#active_for_authentication?" do
    context "if #require_registration_approval is set in the current site" do
      before { Site.current.update_attributes(:require_registration_approval => true) }

      context "true if the user was approved" do
        let(:user) { FactoryGirl.create(:user, :approved => true) }
        it { user.should be_active_for_authentication }
      end

      context "false if the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.should_not be_active_for_authentication }
      end
    end

    context "if #require_registration_approval is not set in the current site" do
      context "true even if the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.should be_active_for_authentication }
      end
    end
  end

  describe "#inactive_message" do
    context "if #require_registration_approval is set in the current site" do
      before { Site.current.update_attributes(:require_registration_approval => true) }

      context "if the user was approved" do
        let(:user) { FactoryGirl.create(:user, :approved => true) }
        it { user.inactive_message.should be(:inactive) }
      end

      context "if the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.inactive_message.should be(:not_approved) }
      end
    end

    context "if #require_registration_approval is not set in the current site" do
      context "ignores the fact that the user was not approved" do
        let(:user) { FactoryGirl.create(:user, :approved => false) }
        it { user.inactive_message.should be(:inactive) }
      end
    end
  end

  describe "#enabled?" do
    let(:user) { FactoryGirl.create(:user) }

    context "if the user is not disabled" do
      it { user.enabled?.should be(true) }
      it { user.disabled?.should be(false) }
    end

    context "if the user is disabled" do
      before { user.disable }
      it { user.enabled?.should be(false) }
      it { user.disabled?.should be(true) }
    end
  end

  describe "#pending_spaces" do
    before do
      @spaces = [
        FactoryGirl.create(:space),
        FactoryGirl.create(:space),
        FactoryGirl.create(:space),
        FactoryGirl.create(:space, :disabled => true)]
      @user = FactoryGirl.create(:user)

      FactoryGirl.create(:join_request, :candidate => @user, :group => @spaces[0], :request_type => JoinRequest::TYPES[:request])
      FactoryGirl.create(:join_request, :candidate => @user, :group => @spaces[1], :request_type => JoinRequest::TYPES[:invite])
      FactoryGirl.create(:join_request, :candidate => @user, :group => @spaces[3], :request_type => JoinRequest::TYPES[:request])
    end

    # Currently makes no differentiation between invites or requests
    # skip "removes possible duplicates"
    it "returns all spaces in which the user has a pending join request he sent" do
      @user.pending_spaces.should include(@spaces[0], @spaces[1])
    end
    it "returns all spaces in which the user has a pending join request he received" do
      @user.pending_spaces.should include(@spaces[1])
    end

    it { @user.pending_spaces.should_not include(@spaces[2]) }

    it "doesn't return spaces that are disabled" do
      @user.pending_spaces.should_not include(@spaces[3])
    end
  end

  describe "#created_by_shib?" do
    let(:user) { FactoryGirl.create(:user) }

    context "when the user has no token" do
      it { user.created_by_shib?.should be(false) }
    end

    context "when the user has a token associated with an existing account" do
      before {
        FactoryGirl.create(:shib_token, user: user, new_account: false)
      }
      it { user.created_by_shib?.should be(false) }
    end

    context "when another user has a token created by shib" do
      let(:another_user) { FactoryGirl.create(:user) }
      before {
        FactoryGirl.create(:shib_token, user: user, new_account: false)
        FactoryGirl.create(:shib_token, user: another_user, new_account: true)
      }
      it { user.created_by_shib?.should be(false) }
    end

    context "when the user has an account created by shib" do
      before {
        FactoryGirl.create(:shib_token, user: user, new_account: true)
      }
      it { user.created_by_shib?.should be(true) }
    end
  end

  describe "#created_by_certificate?" do
    let(:user) { FactoryGirl.create(:user) }

    context "when the user has no token" do
      it { user.created_by_certificate?.should be(false) }
    end

    context "when the user has a token associated with an existing account" do
      before {
        FactoryGirl.create(:certificate_token, user: user, new_account: false)
      }
      it { user.created_by_certificate?.should be(false) }
    end

    context "when another user has a token created by certificate" do
      let(:another_user) { FactoryGirl.create(:user) }
      before {
        FactoryGirl.create(:certificate_token, user: user, new_account: false)
        FactoryGirl.create(:certificate_token, user: another_user, new_account: true)
      }
      it { user.created_by_certificate?.should be(false) }
    end

    context "when the user has an account created by certificate" do
      before {
        FactoryGirl.create(:certificate_token, user: user, new_account: true)
      }
      it { user.created_by_certificate?.should be(true) }
    end
  end

  describe "created by social_login" do
    context "check that the google login is confirmed" do
      let(:omniauth_data) { OmniAuth::AuthHash.new({
                             :provider => "google_oauth2",
                             :uid => "123456789",
                             :info => {
                                 :name => "Google User",
                                 :email => "googleuser@gmail.com"
                               },
                             :credentials => {
                                 :token => "token",
                                 :refresh_token => "refresh token"
                               }
                             }
                           )
                          }

      let!(:google_user) { User.from_omniauth(omniauth_data) }
      it { google_user.confirmed?.should eql(true) }
    end

    context "check that the facebook login is confirmed" do
      let(:omniauth_data) { OmniAuth::AuthHash.new({
                              :provider => "facebook",
                              :uid => "123456789",
                              :info => {
                                  :name => "Face User",
                                  :email => "faceuser@face.com"
                                },
                              :credentials => {
                                  :token => "token",
                                  :refresh_token => "refresh token"
                                }
                              }
                            )
                          }

      let!(:facebook_user) { User.from_omniauth(omniauth_data) }
      it { facebook_user.confirmed?.should eql(true) }
    end
  end

  describe "#local_auth?" do
    it "false if has LDAP auth"
    it "false if has shibboleth auth"
    it "false if has certificate auth"
    it "true if has no LDAP nor shibboleth auth"
  end

  it "#sign_in_methods"

  describe "#last_sign_in_date" do
    it "returns the last sign in date"
    it "returns the same as #current_sign_in_at"
    it "prioritizes shib, ldap and certificate over local"
  end

  describe "#last_sign_method" do
    it "returns 'ldap' if the last method was LDAP"
    it "returns 'shibboleth' if the last method was Shibboleth"
    it "returns 'local' if the last method was local"
    it "returns nil if the user never signed in"
  end

  describe "#superuser" do
    it("true if the user is an admin") { FactoryGirl.create(:superuser).superuser.should be(true) }
    it("false if the user is not an admin") { FactoryGirl.create(:user).superuser.should be(false) }
  end

  describe "#superuser?" do
    it("true if the user is an admin") { FactoryGirl.create(:superuser).superuser?.should be(true) }
    it("false if the user is not an admin") { FactoryGirl.create(:user).superuser?.should be(false) }
  end

  describe "#set_superuser!" do
    context "setting to true" do
      let(:user) { FactoryGirl.create(:user) }
      it {
        user.superuser.should be(false)
        user.set_superuser!
        user.reload.superuser.should be(true)
      }
    end

    context "setting to false" do
      let(:user) { FactoryGirl.create(:superuser) }
      it {
        user.superuser.should be(true)
        user.set_superuser!(false)
        user.reload.superuser.should be(false)
      }
    end
  end

  describe "#disable" do
    let(:user) { FactoryGirl.create(:user) }

    it "sets #disabled to true" do
      user.disabled.should be(false)
      user.disable
      user.reload.disabled.should be(true)
    end

    context "removes all permissions" do
      let(:space) { FactoryGirl.create(:space) }
      before { space.add_member!(user) }

      it { expect { user.disable }.to change(Permission, :count).by(-1) }
    end

    context 'removes the join requests' do
      let(:space) { FactoryGirl.create(:space) }
      let!(:space_join_request) { FactoryGirl.create(:join_request_invite, candidate: user) }
      let!(:space_join_request_invite) { FactoryGirl.create(:join_request_invite, candidate: user, group: space) }
      it { expect { user.disable }.to change(JoinRequest, :count).by(-2) }
    end

    context "doesn't remove the invitations the user sent" do
      let!(:join_request_invite) { FactoryGirl.create(:join_request_invite, introducer: user) }
      it { expect { user.disable }.not_to change(JoinRequest, :count) }
    end

    context "when the user is admin of a space" do
      let(:space) { FactoryGirl.create(:space) }

      context "and is the last admin left" do
        before(:each) do
          space.add_member!(user, 'Admin')
          user.disable
        end

        it { user.disabled.should be(true) }
        it { space.reload.disabled.should be(true) }
      end

      context "and is the last admin left and there are other members" do
        let(:user2) { FactoryGirl.create(:user) }
        before(:each) do
          space.add_member!(user, 'Admin')
          space.add_member!(user2, 'User')
          user.disable
        end

        it { user.disabled.should be(true) }
        it { space.reload.disabled.should be(true) }
      end

      context "and isn't the last admin left" do
        let(:user2) { FactoryGirl.create(:user) }
        before(:each) do
          space.add_member!(user, 'Admin')
          space.add_member!(user2, 'Admin')
          user.disable
        end

        it { user.disabled.should be(true) }
        it { space.disabled.should be(false) }
      end

      context "doesn't break if there are disabled spaces" do
        let(:space2) { FactoryGirl.create(:space) }
        before(:each) do
          space.add_member!(user, 'Admin')
          space2.add_member!(user, 'Admin')
          space2.disable
          user.disable
        end

        it { user.disabled.should be(true) }
        it { space.reload.disabled.should be(true) }
      end

    end
  end

  describe "#member_of?" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }

    context "when the user is not a member of the space" do
      it { user.member_of?(space).should be(false) }
    end

    context "when the user is a user of the space" do
      before { space.add_member!(user, 'User') }
      it { user.member_of?(space).should be(true) }
    end

    context "when the user is an admin of the space" do
      before { space.add_member!(user, 'Admin') }
      it { user.member_of?(space).should be(true) }
    end
  end

  describe "#update_webconf_room" do
    let(:user) { FactoryGirl.create(:user) }

    context "updates the slug" do
      let(:user) { FactoryGirl.create(:user, slug: "old-slug") }
      before(:each) { user.update_attributes(slug: "new-slug") }
      it { user.slug.should eql("new-slug") }
      it { user.bigbluebutton_room.slug.should eql("new-slug") }
    end

    context "updates the slug even if it was already changed directly before" do
      let(:user) { FactoryGirl.create(:user, slug: "old-slug") }
      before(:each) {
        user.bigbluebutton_room.update_attributes(slug: "custom-slug")
        user.update_attributes(slug: "new-slug")
      }
      it { user.slug.should eql("new-slug") }
      it { user.bigbluebutton_room.slug.should eql("new-slug") }
    end
  end

  describe "#location" do
    context "returns the city + country" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        user.profile.city = "City X"
        user.profile.country = "Country Y"
        user.save!
      }
      it { user.location.should eql("City X, Country Y") }
    end

    context "returns the city if country if not defined" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        user.profile.city = "City X"
        user.profile.country = nil
        user.save!
      }
      it { user.location.should eql("City X") }
    end

    context "returns the country if city if not defined" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        user.profile.city = nil
        user.profile.country = "Country Y"
        user.save!
      }
      it { user.location.should eql("Country Y") }
    end
  end

  describe "#cant_record_reason" do
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    let(:user) { FactoryGirl.create(:user, bigbluebutton_room: room) }

    context "returns the reason if the user can't record" do
      before { user.update_attributes(can_record: false) }
      it { user.cant_record_reason(room).should eql(I18n.t('users.cant_record_reason.user_cannot_record')) }
    end

    context "returns nil if the user can record" do
      before { user.update_attributes(can_record: true) }
      it { user.cant_record_reason(room).should be_nil }
    end
  end

  # TODO: :index is nested into spaces, how to test it here?
  describe "abilities", :abilities => true do

    set_custom_ability_actions([
      :fellows, :current, :select, :approve, :enable, :disable, :confirm,
      :update_password, :update_logo, :update_full_name
    ])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:user) }

    context "when is the user himself" do
      let(:user) { target }
      it {
        allowed = [:show, :index, :edit, :update, :disable, :fellows, :current, :select,
                   :update_password, :update_logo, :update_full_name]
        should_not be_able_to_do_anything_to(target).except(allowed)
      }

      context "and he is disabled" do
        before { target.disable }
        it { should_not be_able_to_do_anything_to(target).except(:index) }
      end

      context "cannot edit the password if the account was created by shib" do
        before {
          Site.current.update_attributes(local_auth_enabled: true)
          FactoryGirl.create(:shib_token, user: target, new_account: true)
        }
        it { should_not be_able_to(:update_password, target) }
      end

      context "can edit the password if the account was not created by shib" do
        before {
          Site.current.update_attributes(local_auth_enabled: true)
          FactoryGirl.create(:shib_token, user: target, new_account: false)
        }
        it { should be_able_to(:update_password, target) }
      end

      context "cannot edit the password if the account was created by LDAP" do
        before {
          Site.current.update_attributes(local_auth_enabled: true)
          FactoryGirl.create(:ldap_token, user: target, new_account: true)
        }
        it { should_not be_able_to(:update_password, target) }
      end

      context "can edit the password if the account was not created by LDAP" do
        before {
          Site.current.update_attributes(local_auth_enabled: true)
          FactoryGirl.create(:ldap_token, user: target, new_account: false)
        }
        it { should be_able_to(:update_password, target) }
      end

      context "cannot edit the password if the site has local auth disabled" do
        before {
          Site.current.update_attributes(local_auth_enabled: false)
          FactoryGirl.create(:shib_token, user: target, new_account: false)
        }
        it { should_not be_able_to(:update_password, target) }
      end

      context "cannot edit the full name if the account was created by shib" do
        before {
          Site.current.update_attributes(shib_update_users: true)
          FactoryGirl.create(:shib_token, user: target, new_account: true)
        }
        it { should_not be_able_to(:update_full_name, target) }
      end

      context "can edit the full name if the account was not created by shib" do
        before {
          Site.current.update_attributes(shib_update_users: true)
          FactoryGirl.create(:shib_token, user: target, new_account: false)
        }
        it { should be_able_to(:update_full_name, target) }
      end

      context "can edit the full name if the site is not updating user information automatically" do
        before {
          Site.current.update_attributes(shib_update_users: false)
          FactoryGirl.create(:shib_token, user: target, new_account: true)
        }
        it { should be_able_to(:update_full_name, target) }
      end
    end

    context "when is another normal user" do
      let(:user) { FactoryGirl.create(:user) }
      it { should_not be_able_to_do_anything_to(target).except([:show, :index, :current, :fellows, :select]) }

      context "and the target user is disabled" do
        before { target.disable }
        it { should_not be_able_to_do_anything_to(target).except(:index) }
      end

      context "cannot edit the password even if the account was not created by shib" do
        before {
          Site.current.update_attributes(local_auth_enabled: true)
          FactoryGirl.create(:shib_token, user: target, new_account: false)
        }
        it { should_not be_able_to(:update_password, target) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to_do_everything_to(target) }

      context "and the target user is disabled" do
        before { target.disable }
        it { should be_able_to_do_everything_to(target) }
      end

      context "over his own account" do
        it { should be_able_to_do_everything_to(target) }
      end

      context "he can do anything over all resources" do
        it { should be_able_to_do_everything_to(:all) }
      end

      context "over a normal user" do
        context "cannot edit the password if the account was created by shib" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:shib_token, user: target, new_account: true)
          }
          it { should_not be_able_to(:update_password, target) }
        end

        context "can edit the password if the account was not created by shib" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:shib_token, user: target, new_account: false)
          }
          it { should be_able_to(:update_password, target) }
        end

        context "cannot edit the password if the account was created by LDAP" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:ldap_token, user: target, new_account: true)
          }
          it { should_not be_able_to(:update_password, target) }
        end

        context "can edit the password if the account was not created by LDAP" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:ldap_token, user: target, new_account: false)
          }
          it { should be_able_to(:update_password, target) }
        end

        context "cannot edit the password if the site has local auth disabled" do
          before {
            Site.current.update_attributes(local_auth_enabled: false)
            FactoryGirl.create(:shib_token, user: target, new_account: false)
          }
          it { should_not be_able_to(:update_password, target) }
        end
      end

      context "over a superuser" do
        before {
          target.set_superuser!(true)
        }

        context "cannot edit the password if the account was created by shib" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:shib_token, user: target, new_account: true)
          }
          it { should_not be_able_to(:update_password, target) }
        end

        context "can edit the password if the account was not created by shib" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:shib_token, user: target, new_account: false)
          }
          it { should be_able_to(:update_password, target) }
        end

        context "cannot edit the password if the account was created by LDAP" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:ldap_token, user: target, new_account: true)
          }
          it { should_not be_able_to(:update_password, target) }
        end

        context "can edit the password if the account was not created by LDAP" do
          before {
            Site.current.update_attributes(local_auth_enabled: true)
            FactoryGirl.create(:ldap_token, user: target, new_account: false)
          }
          it { should be_able_to(:update_password, target) }
        end

        context "can edit the password even if the site has local auth disabled" do
          before {
            Site.current.update_attributes(local_auth_enabled: false)
            FactoryGirl.create(:shib_token, user: target, new_account: false)
          }
          it { should be_able_to(:update_password, target) }
        end
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }
      it { should_not be_able_to_do_anything_to(target).except([:show, :index, :current]) }

      context "and the target user is disabled" do
        before { target.disable }
        it { should_not be_able_to_do_anything_to(target).except(:index) }
      end
    end
  end

end
