# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe JoinRequest, type: :model do

  it { should belong_to(:candidate) }
  it { should belong_to(:introducer) }
  it { should belong_to(:group) }
  it { should belong_to(:role) }

  describe 'validations' do
    # We need to setup a different 'subject' so that all validation matchers work
    subject { FactoryGirl.create(:join_request) }

    it { should validate_presence_of(:email) }

    it { should validate_presence_of(:request_type) }

    it { should validate_presence_of(:candidate_id) }

    it { should validate_length_of(:comment).is_at_most(255) }

    skip "validates email (we need a matcher for the email validation gem)" do
      should validate_email(:email)
    end

    it { should validate_uniqueness_of(:candidate_id).scoped_to(:group_id, :group_type, :processed_at) }

    it { should validate_uniqueness_of(:email).scoped_to(:group_id, :group_type, :processed_at) }
  end

  it { should respond_to(:"processed=") }

  describe "sets processed_at when the model is saved with processed==true" do
    let(:jr) { FactoryGirl.create(:join_request) }

    it { jr.processed_at.should_not be_present }

    context "setting processed == true" do
      let!(:current_time) { Time.now }
      before { jr.update_attributes(processed: true) }

      it { jr.processed_at.should be_present }
      it { jr.processed_at.should be_within(5.minutes).of(current_time) }
    end

  end

  skip "throws an error if the candidate is the introducer" do
    let(:user) { FactoryGirl.create(:user) }
    let(:jr) { FactoryGirl.create(:join_request, candidate: user, introducer: user) }
    it { jr.errors.should be_present }
    it { jr.should_not be_persisted }
  end

  describe "adds member before save" do
    let(:jr) { FactoryGirl.build(:join_request, group: FactoryGirl.create(:space), candidate: FactoryGirl.create(:user), accepted: accepted) }
    let(:space) { jr.group }

    context "when accepted==true" do
      let(:accepted) { true }

      it { expect{jr.save}.to change{space.users.count}.by(1) }

      context "but don't do it when saving again and already a member" do
        before { space.add_member!(jr.candidate) }

        it { expect{jr.save}.to change{space.users.count}.by(0) }
      end
    end

    context "when accepted==false" do
      let(:accepted) { false }

      it { expect{jr.save}.to change{space.users.count}.by(0) }
    end

  end

  context "initializes" do
    let(:target) { JoinRequest.new }

    context "secret_token" do
      context "with a random hash" do
        it { target.secret_token.should_not be_nil }
        it { target.secret_token.length.should >= 22 }
      end

      it("doesn't regenerate the secret token") {
        b = JoinRequest.new(:secret_token => "user defined")
        b.secret_token.should == "user defined"
      }
    end
  end

  context ".to_param" do
    it { should respond_to(:to_param) }
    it {
      jr = FactoryGirl.create(:join_request)
      jr.to_param.should be(jr.secret_token)
    }
  end

  describe "#processed?" do
    let(:target) { FactoryGirl.create(:join_request) }

    context "if processed_at is set" do
      before { target.update_attributes(:processed_at => Time.now.utc) }
      it { target.processed?.should be_truthy }
    end

    context "if processed_at is not set" do
      before { target.update_attributes(:processed_at => nil) }
      it { target.processed?.should be_falsey }
    end
  end

  describe "#recently_processed?" do
    let(:target) { FactoryGirl.create(:join_request) }

    context "if processed is set" do
      before { target.processed = Time.now.utc }
      it { target.recently_processed?.should be_truthy }
    end

    context "if processed_at is not set" do
      before { target.processed = nil }
      it { target.recently_processed?.should be_falsey }
    end
  end

  describe "#role" do
    let(:jr) { FactoryGirl.create(:join_request, role: role) }

    context "with nil role_id returns the default role" do
      let(:role) { nil }

      it { jr.should be_persisted }
      it { jr.role.should eq(JoinRequest.default_role) }
    end

    context ".role returns the role associated to the join request" do
      let(:role) { Role.where(stage_type: 'Space', name: 'Admin').first }

      it { jr.should be_persisted }
      it { jr.role.should eq(role) }
    end

    context "set role with role_id" do
      let(:role) { nil }
      let(:new_role) { Role.where(stage_type: 'Event').first }

      before { jr.update_attributes(role_id: new_role.id) }

      it { jr.role.should eq(new_role) }
    end

  end

  describe "#space?" do
    context "if group is a Space" do
      let(:target) { FactoryGirl.create(:space_join_request) }
      it { target.space?.should be_truthy }
    end

    context "if group is not a Space" do
      let(:target) { FactoryGirl.create(:join_request, :group => FactoryGirl.create(:event)) }
      it { target.space?.should be_falsey }
    end
  end

  describe "#is_invite?" do
    context "when it is an invitation" do
      let(:target) { FactoryGirl.create(:join_request, request_type: JoinRequest::TYPES[:invite]) }
      it { target.is_invite?.should be(true) }
    end

    context "when it is not an invitation" do
      ["request", "no_accept"].each do |value|
        context "for #{value}" do
          let(:target) { FactoryGirl.create(:join_request, request_type: value) }
          it { target.is_invite?.should be(false) }
        end
      end
    end
  end

  describe "#is_request?" do
    context "when it is an request" do
      let(:target) { FactoryGirl.create(:join_request, request_type: JoinRequest::TYPES[:request]) }
      it { target.is_request?.should be(true) }
    end

    context "when it is not a request" do
      ["invite", "no_accept"].each do |value|
        context "for #{value}" do
          let(:target) { FactoryGirl.create(:join_request, request_type: value) }
          it { target.is_request?.should be(false) }
        end
      end
    end
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:accept, :decline])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:space_join_request) }

    context "when is an anonymous user" do
      let(:user) { User.new }

      context "in a public space" do
        before { target.group.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "in a private space" do
        before { target.group.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "and the target space is disabled" do
        before { target.group.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "and the target space is not approved" do
        before { target.group.update_attributes(approved: false) }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      [true, false].each do |is_public|

        context "in a #{is_public ? 'public' : 'private'} space" do
          before { target.group.update_attributes(public: is_public) }

          context "he is not a member of" do
            it { should_not be_able_to_do_anything_to(target).except([:create, :new]) }
          end

          context "he is not a member and is being invited to the space" do
            before do
              target.candidate = user
              target.request_type = JoinRequest::TYPES[:invite]
            end

            it { should_not be_able_to_do_anything_to(target).except([:accept, :create, :new, :decline]) }
          end

          context "he is a member of" do
            context "with the role 'Admin'" do
              before { target.group.add_member!(user, "Admin") }

              context "over a request" do
                it { should be_able_to(:manage_join_requests, target.group) }
                it { should_not be_able_to_do_anything_to(target).except([:accept, :create, :new, :decline]) }
              end

              context "over an invitation" do
                before { target.request_type = JoinRequest::TYPES[:invite] }
                it { should be_able_to(:manage_join_requests, target.group) }
                it { should_not be_able_to_do_anything_to(target).except([:create, :new, :decline]) }
              end
            end

            context "with the role 'User'" do
              before { target.group.add_member!(user, "User") }

              context "over a request" do
                it { should_not be_able_to_do_anything_to(target).except([:create, :new]) }
              end

              context "over an invitation" do
                before { target.request_type = JoinRequest::TYPES[:invite] }
                it { should_not be_able_to_do_anything_to(target).except([:create, :new]) }
              end
            end

            context "and the target space is disabled" do
              before { target.group.disable }
              it { should_not be_able_to_do_anything_to(target).except([:create, :new]) }
            end

            context "and the target space is not approved" do
              before { target.group.update_attributes(approved: false) }
              it { should_not be_able_to_do_anything_to(target) }
            end
          end
        end

      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in a public space" do
        before { target.group.update_attributes(:public => true) }
        it { should be_able_to_do_everything_to(target) }
      end

      context "in a private space" do
        before { target.group.update_attributes(:public => false) }
        it { should be_able_to_do_everything_to(target) }
      end

      context "and the target space is disabled" do
        before { target.group.disable }
        it { should be_able_to_do_everything_to(target) }
      end

      context "and the target space is not approved" do
        before { target.group.update_attributes(approved: false) }
        it { should be_able_to_do_everything_to(target) }
      end
    end
  end

end
