# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpaceEventsController, :events => true do

  before(:each, :events => true) do
    Site.current.update_attributes(:events_enabled => true)
  end

  describe "#index" do
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) { sign_in(user) }

    context "layout and view" do
      before(:each) { get :index, :space_id => space.to_param }
      it { should render_template(/index/) }
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
    let(:hash) { { :space_id => target.owner.to_param } }
    let(:hash_with_id) { hash.merge!(:id => target.to_param) }
    let(:hash_with_attrs) { hash_with_id.merge!(:event => attrs) }

    context "for a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(user) }

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
        let(:target) { FactoryGirl.create(:event, :owner => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          skip "more tests that are not in the engine"
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }
              it { should allow_access_to(:index, hash) }
              skip "more tests that are not in the engine"
            end
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        let(:target) { FactoryGirl.create(:event, :owner => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          skip "more tests that are not in the engine"
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }
              it { should allow_access_to(:index, hash) }
              skip "more tests that are not in the engine"
            end
          end
        end
      end

    end

    context "for a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) { login_as(user) }

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
        let(:target) { FactoryGirl.create(:event, :owner => space) }

        context "he is not a member of" do
          it { should allow_access_to(:index, hash) }
          skip "more tests that are not in the engine"
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }

              context "for an event he did not create" do
                it { should allow_access_to(:index, hash) }
                skip "more tests that are not in the engine"
              end

              context "for an event he created" do
                let(:target) { FactoryGirl.create(:event, :owner => space) }

                it { should allow_access_to(:index, hash) }
                skip "more tests that are not in the engine"
              end

            end
          end
        end
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        let(:target) { FactoryGirl.create(:event, :owner => space) }

        context "he is not a member of" do
          it { should_not allow_access_to(:index, hash) }
          skip "more tests that are not in the engine"
        end

        context "he is a member of" do
          Space::USER_ROLES.each do |role|
            context "with the role '#{role}'" do
              before(:each) { space.add_member!(user, role) }

              context "for an event he did not create" do
                it { should allow_access_to(:index, hash) }
                skip "more tests that are not in the engine"
              end

              context "for an event he created" do
                let(:target) { FactoryGirl.create(:event, :owner => space) }

                it { should allow_access_to(:index, hash) }
                skip "more tests that are not in the engine"
              end
            end
          end
        end
      end

    end

    context "for an anonymous user", :user => "anonymous" do

      context "in a public space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
        let(:target) { FactoryGirl.create(:event, :owner => space) }
        it { should allow_access_to(:index, hash) }
        skip "more tests that are not in the engine"
      end

      context "in a private space" do
        let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
        let(:target) { FactoryGirl.create(:event, :owner => space) }
        it { should_not allow_access_to(:index, hash) }
        skip "more tests that are not in the engine"
      end
    end

  end
end
