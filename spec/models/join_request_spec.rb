require 'spec_helper'

describe JoinRequest do

  it "belongs to candidate"
  it "belongs to introducer"
  it "belongs to group"
  it "has one role"

  it { should validate_presence_of(:email) }
  it "validates format of email"

  it { should respond_to(:"processed=") }
  it "sets processed_at when the model is saved with processed==true"
  it "adds member to group when saved with accepted==true"
  it "validates uniqueness of candidate_id"
  it "validates uniqueness of email"

  it "throws an error if the candidate is the introducer"

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
    it "returns the role associated with the join request"
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

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:approve, :accept])

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
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      context "in a public space" do
        before { target.group.update_attributes(:public => true) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except(:create) }
        end

        context "he is not a member and is being invited to the space" do
          before do 
            target.candidate = user
            target.request_type = 'invite'
          end

          it { should_not be_able_to_do_anything_to(target).except([:accept, :show, :create, :update, :destroy]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.group.add_member!(user, "Admin") }
            it { should be_able_to(:index_join_requests, target.group) }
            it { should be_able_to(:invite, target.group) }
            it { should_not be_able_to_do_anything_to(target).except([:approve, :show, :update, :destroy, :create]) }
          end

          context "with the role 'User'" do
            before { target.group.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except(:create) }
          end
        end
      end

      context "in a private space" do
        before { target.group.update_attributes(:public => false) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except(:create) }
        end

        context "he is not a member and is being invited to the space" do
          before do
            target.candidate = user
            target.request_type = 'invite'
          end

          it { should_not be_able_to_do_anything_to(target).except([:accept, :show, :create, :update, :destroy]) }
        end

        context "he is not a member and is requesting membership" do
          before do
            target.candidate = user
            target.request_type = 'request'
          end

          it { should_not be_able_to_do_anything_to(target).except([:show, :create, :update, :destroy]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { target.group.add_member!(user, "Admin") }
            it { should be_able_to(:index_join_requests, target.group) }
            it { should be_able_to(:invite, target.group) }
            it { should_not be_able_to_do_anything_to(target).except([:approve, :show, :update, :destroy, :create]) }
          end

          context "with the role 'User'" do
            before { target.group.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except(:create) }
          end
        end
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }

      context "in a public space" do
        before { target.group.update_attributes(:public => true) }
        it { should be_able_to(:manage, target) }
      end

      context "in a private space" do
        before { target.group.update_attributes(:public => false) }
        it { should be_able_to(:manage, target) }
      end
    end
  end

end
