# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpaceEventsController do

  describe "#index" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "layout and view" do
      before(:each) { get :index, :space_id => space.to_param }
      it { should render_template("events/index") }
      it { should render_with_layout("spaces_show") }
    end

    it "assigns @space"
    it "assigns @events"
    it "assigns @current_events"

    context "if params[:show] == 'past_events'" do
      it "assigns @past_events"
    end
    context "if params[:show] == 'upcoming_events'" do
      it "assigns @upcoming_events"
    end
    context "if params[:show] not set or invalid" do
      it "assigns @last_past_events"
      it "assigns @first_upcoming_events"
    end
  end

  describe "#index.atom" do
    it "returns an rss with all the events in the space"
  end

  # TODO: #1115, review
  describe "abilities", :abilities => true do
    render_views(false)

    let(:attrs) { FactoryGirl.attributes_for(:event) }
    let(:hash) { { :space_id => target.space.to_param } }
    let(:hash_with_id) { hash.merge!(:id => target.to_param) }
    let(:hash_with_attrs) { hash_with_id.merge!(:event => attrs) }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }

      context "in a public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          it { should allow_access_to(:new, hash) }
          it { should allow_access_to(:create, hash).via(:post) }
          it { should allow_access_to(:show, hash_with_id) }
          it { should allow_access_to(:edit, hash_with_id) }
          it { should allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }
              it { should allow_access_to(:index, hash) }
              it { should allow_access_to(:new, hash) }
              it { should allow_access_to(:create, hash).via(:post) }
              it { should allow_access_to(:show, hash_with_id) }
              it { should allow_access_to(:edit, hash_with_id) }
              it { should allow_access_to(:update, hash_with_attrs).via(:post) }
              it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            end
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          it { should allow_access_to(:new, hash) }
          it { should allow_access_to(:create, hash).via(:post) }
          it { should allow_access_to(:show, hash_with_id) }
          it { should allow_access_to(:edit, hash_with_id) }
          it { should allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }
              it { should allow_access_to(:index, hash) }
              it { should allow_access_to(:new, hash) }
              it { should allow_access_to(:create, hash).via(:post) }
              it { should allow_access_to(:show, hash_with_id) }
              it { should allow_access_to(:edit, hash_with_id) }
              it { should allow_access_to(:update, hash_with_attrs).via(:post) }
              it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
            end
          end
        end
      end

    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      context "in a public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          it { should_not allow_access_to(:new, hash) }
          it { should_not allow_access_to(:create, hash).via(:post) }
          it { should allow_access_to(:show, hash_with_id) }
          it { should_not allow_access_to(:edit, hash_with_id) }
          it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }

              context "for an event he did not create" do
                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should_not allow_access_to(:edit, hash_with_id) }
                it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end

              context "for an event he created" do
                let(:target) { FactoryGirl.create(:event, :space => space, :author => user) }

                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should allow_access_to(:edit, hash_with_id) }
                it { should allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end

            end
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }

        context "he is not a member of" do
          it { should_not allow_access_to(:index, hash) }
          it { should_not allow_access_to(:new, hash) }
          it { should_not allow_access_to(:create, hash).via(:post) }
          it { should_not allow_access_to(:show, hash_with_id) }
          it { should_not allow_access_to(:edit, hash_with_id) }
          it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
          it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }

              context "for an event he did not create" do
                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should_not allow_access_to(:edit, hash_with_id) }
                it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end

              context "for an event he created" do
                let(:target) { FactoryGirl.create(:event, :space => space, :author => user) }

                it { should allow_access_to(:index, hash) }
                it { should allow_access_to(:new, hash) }
                it { should allow_access_to(:create, hash).via(:post) }
                it { should allow_access_to(:show, hash_with_id) }
                it { should allow_access_to(:edit, hash_with_id) }
                it { should allow_access_to(:update, hash_with_attrs).via(:post) }
                it { should allow_access_to(:destroy, hash_with_attrs).via(:delete) }
              end
            end
          end
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do

      context "in a public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }
        it { should allow_access_to(:index, hash) }
        it { should_not allow_access_to(:new, hash) }
        it { should_not allow_access_to(:create, hash).via(:post) }
        it { should allow_access_to(:show, hash_with_id) }
        it { should_not allow_access_to(:edit, hash_with_id) }
        it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, :space => space) }
        it { should_not allow_access_to(:index, hash) }
        it { should_not allow_access_to(:new, hash) }
        it { should_not allow_access_to(:create, hash).via(:post) }
        it { should_not allow_access_to(:show, hash_with_id) }
        it { should_not allow_access_to(:edit, hash_with_id) }
        it { should_not allow_access_to(:update, hash_with_attrs).via(:post) }
        it { should_not allow_access_to(:destroy, hash_with_attrs).via(:delete) }
      end
    end

  end

end
