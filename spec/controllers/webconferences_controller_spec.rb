# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe WebconferencesController do
  render_views

  describe "abilities" do
    render_views(false)

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      let(:space) { FactoryGirl.create(:space) }
      let(:hash_space) { { :space_id => space.to_param } }
      let(:hash_user) { { :user_id => user.to_param } }
      let(:hash_another_user) { { :user_id => FactoryGirl.create(:user).to_param } }
      before(:each) { login_as(user) }

      context "in his room" do
        it { should allow_access_to(:user_edit, hash_user) }
      end

      context "in another user's room" do
        it { should allow_access_to(:user_edit, hash_another_user) }
      end

      context "in the room of a space" do
        context "he is a member of" do
          before { space.add_member!(user) }
          it { should allow_access_to(:space_show, hash_space) }
        end

        context "he is not a member of" do
          it { should allow_access_to(:space_show, hash_space) }
        end
      end
    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      let(:hash_space) { { :space_id => space.to_param } }
      let(:hash_user) { { :user_id => user.to_param } }
      let(:hash_another_user) { { :user_id => FactoryGirl.create(:user).to_param } }
      before(:each) { login_as(user) }

      context "in his room" do
        it { should allow_access_to(:user_edit, hash_user) }
      end

      context "in another user's room" do
        it { should_not allow_access_to(:user_edit, hash_another_user) }
      end

      context "in the room of a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }

        context "he is a member of" do
          before { space.add_member!(user) }
          it { should allow_access_to(:space_show, hash_space) }
        end

        context "he is not a member of" do
          it { should allow_access_to(:space_show, hash_space) }
        end
      end

      context "in the room of a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }

        context "he is a member of" do
          before { space.add_member!(user) }
          it { should allow_access_to(:space_show, hash_space) }
        end

        context "he is not a member of" do
          it { should_not allow_access_to(:space_show, hash_space) }
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do
      let(:hash_space) { { :space_id => space.to_param } }
      let(:hash_another_user) { { :user_id => FactoryGirl.create(:user).to_param } }

      context "in a user's room" do
        it { should_not allow_access_to(:user_edit, hash_another_user) }
      end

      context "in the room of a public space" do
        let(:space) { FactoryGirl.create(:space, :public => true) }
        it { should_not allow_access_to(:space_show, hash_space) }
      end

      context "in the room of a private space" do
        let(:space) { FactoryGirl.create(:space, :public => false) }
        it { should_not allow_access_to(:space_show, hash_space) }
      end
    end
  end

  describe "#space_show" do
    it "assigns @space"
    it "assigns @room"
    it "assigns @webconf_attendees with the attendees"
    it "uses the layout 'spaces_show'"
  end

  describe "#user_edit" do
    it "assigns @room"
    it "assigns @redirect_to"
    it "uses the layout 'application'"
    it "uses no layout if xhr"
  end

end
