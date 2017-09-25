# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Check that @spaces_examples is assigned properly.
#
# Arguments:
#   do_action: the action to be called
#
# Example:
#   let(:do_action) { get :new }
#   it_should_behave_like "assigns @spaces_examples"
#
shared_examples_for "assigns @spaces_examples" do
  it "assigns the variable" do
    do_action
    should assign_to(:spaces_examples)
  end

  context "includes all types of spaces" do
    before {
      @s1 = FactoryGirl.create(:space)
      @s2 = FactoryGirl.create(:public_space)
      @s3 = FactoryGirl.create(:public_space)
      @s4 = FactoryGirl.create(:private_space)
      @s5 = FactoryGirl.create(:private_space)
    }
    before(:each) { do_action }
    it { assigns(:spaces_examples).should be_include(@s1) }
    it { assigns(:spaces_examples).should be_include(@s2) }
    it { assigns(:spaces_examples).should be_include(@s3) }
    it { assigns(:spaces_examples).should be_include(@s4) }
    it { assigns(:spaces_examples).should be_include(@s5) }
  end

  context "limits to 5 spaces" do
    before { 8.times { FactoryGirl.create(:space) } }
    before(:each) { do_action }
    it { assigns(:spaces_examples).count.should be(5) }
  end

  context "returns only approved spaces if the site requires approval" do
    before {
      Site.current.update_attributes(require_space_approval: true)
      @s1 = FactoryGirl.create(:space, approved: false)
      @s2 = FactoryGirl.create(:space, approved: true)
      @s3 = FactoryGirl.create(:space, approved: false)
      do_action
    }
    it { assigns(:spaces_examples).count.should be(1) }
    it { assigns(:spaces_examples).should be_include(@s2) }
  end
end

shared_examples "an action that rescues from CanCan::AccessDenied" do
  context "when there's a user logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { sign_in(user) }

    context "and the user has no pending join request" do
      before(:each) { do_action }
      it { should redirect_to(new_space_join_request_path(space_id: space)) }
      it { should_not set_flash }
    end

    context "and the user has a pending invitation" do
      before(:each) {
        @invitation = FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => JoinRequest::TYPES[:invite])
      }
      before(:each) { do_action }
      it { space.pending_invitation_for?(user).should be(true) }
      it { should redirect_to(new_space_join_request_path(space_id: space)) }
      it { should_not set_flash }
    end

    context "and the user has a pending join request" do
      before(:each) {
        @invitation = FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => JoinRequest::TYPES[:request])
      }
      before(:each) { do_action }
      it { space.pending_join_request_for?(user).should be(true) }
      it { should redirect_to(new_space_join_request_path(space_id: space)) }
      it { should_not set_flash }
    end
  end

  context "when there's no user logged in" do
    before { do_action }
    it("should ask the user to log in") { should redirect_to login_path }
  end

  it "when it's a user trying to create a space but has no permission"
end

shared_examples "an action that does not rescue from CanCan::AccessDenied" do
  context "when there's a user logged in" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { sign_in(user) }

    context "and the user has no pending join request" do
      it { expect { do_action }.to raise_error(CanCan::AccessDenied) }
    end

    context "and the user has a pending invitation" do
      before(:each) {
        @invitation = FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => JoinRequest::TYPES[:invite])
      }
      it { expect { do_action }.to raise_error(CanCan::AccessDenied) }
    end

    context "and the user has a pending join request" do
      before(:each) {
        @invitation = FactoryGirl.create(:join_request, :group => space, :candidate => user, :request_type => JoinRequest::TYPES[:request])
      }
      it { expect { do_action }.to raise_error(CanCan::AccessDenied) }
    end
  end

  context "when there's no user logged in" do
    before { do_action }
    it("should ask the user to log in") { should redirect_to login_path }
  end
end
