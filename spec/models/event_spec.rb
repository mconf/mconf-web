# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Event do
  before(:each) { Site.current.update_attributes(events_enabled: true) }
  let(:event) { FactoryGirl.create(:event) }

  context "should correct and invalid event date range" do
    let!(:today) { Time.now }
    let(:event) { FactoryGirl.create(:event, :start_on => today, :end_on => today - 1.day) }

    it { event.should be_valid }
    it { event.start_on.should eq(today - 1.day) }
    it { event.end_on.should eq(today) }
  end

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:event).should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:summary).is_at_most(140) }

  it { should have_many(:participants).dependent(:destroy) }

  it { should belong_to(:owner) }

  it { should respond_to(:address) }
  it { should respond_to(:address=) }
  it { should respond_to(:start_on) }
  it { should respond_to(:start_on=) }
  it { should respond_to(:end_on) }
  it { should respond_to(:end_on=) }
  it { should respond_to(:description) }
  it { should respond_to(:description=) }
  it { should respond_to(:location) }
  it { should respond_to(:location=) }
  it { should respond_to(:name) }
  it { should respond_to(:name=) }
  it { should respond_to(:time_zone) }
  it { should respond_to(:time_zone=) }
  it { should respond_to(:social_networks) }
  it { should respond_to(:social_networks=) }
  it { should respond_to(:summary) }
  it { should respond_to(:summary=) }
  it { should respond_to(:owner_id) }
  it { should respond_to(:owner_id=) }
  it { should respond_to(:owner_type) }
  it { should respond_to(:owner_type=) }

  it { should respond_to(:owner_name) }
  it { should respond_to(:owner_name=) }

  describe "#owner_name" do
    skip
  end

  describe "#public" do
    let(:public_event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:space, public: true)) }
    let(:private_event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:space, public: false)) }
    let(:user_event) { FactoryGirl.create(:event, owner: FactoryGirl.create(:user)) }

    it { public_event.public.should be(true) }
    it { private_event.public.should be(false) }
    it { user_event.public.should be(true) }
  end

  describe ".search_by_terms" do
    skip
  end

  describe ".description_html" do
    let(:event) { FactoryGirl.create(:event, description: description) }

    context "with simple markdown syntax" do
      let(:description) { '#Using _markdown_' }
      it { event.description_html.should eq("<h1>Using <em>markdown</em></h1>\n") }
    end

    context "with simple html mixed in" do
      let(:description) { '#Using _markdown_ and some html <p>See?</p>' }

      it { event.description_html.should eq("<h1>Using <em>markdown</em> and some html &lt;p&gt;See?\&lt;/p&gt;</h1>\n") }
    end

    context "with dangerous html mixed in" do
      let(:description) { '#Using _markdown_ and <script>alert(\'Danger\')</script>' }

      it { event.description_html.should eq("<h1>Using <em>markdown</em> and &lt;script&gt;alert(&#39;Danger&#39;)&lt;/script&gt;</h1>\n") }
    end
  end

  context "test time scopes" do
    let!(:today) { Time.now }
    before(:each) do
      @events = [
        FactoryGirl.create(:event, start_on: today - 2.day, end_on: today - 1.day),
        FactoryGirl.create(:event, start_on: today - 1.day, end_on: today - 1.minute),
        FactoryGirl.create(:event, start_on: today - 5.minute, end_on: today + 2.day),
        FactoryGirl.create(:event, start_on: today + 5.minutes, end_on: today + 10.minutes),
        FactoryGirl.create(:event, start_on: today + 1.day, end_on: today + 3.day)
      ]
    end

    describe ".within" do
      it { Event.within(today, today + 2.day).count.should be(3) }
      it { Event.within(today, today + 2.day).should include(@events[2], @events[3], @events[4]) }

      it { Event.within(today + 1.day, today + 2.day).count.should be(2) }
      it { Event.within(today + 1.day, today + 2.day).should include(@events[2], @events[4]) }

      it { Event.within(today + 4.day, today + 5.day).should be_empty }

      it { Event.within(today - 5.day, today - 1.day).count.should eq(2) }
      it { Event.within(today - 5.day, today - 1.day).should include(@events[0], @events[1]) }
    end

    describe ".upcoming" do
      it { Event.upcoming.count.should eq(3) }
      it { Event.upcoming.should include(@events[2], @events[3], @events[4]) }
    end

    describe ".past" do
      it { Event.past.count.should eq(2) }
      it { Event.past.should include(@events[0], @events[1]) }
    end

    describe ".happening now" do
      it { Event.happening_now.count.should eq(1) }
      it { Event.happening_now.should include(@events[2]) }
    end

    describe "#past?" do
      it { @events[0].should be_past }
      it { @events[1].should be_past }
      it { @events[2].should_not be_past }
      it { @events[3].should_not be_past }
      it { @events[4].should_not be_past }
    end

    describe "#is_happening_now?" do
      it { @events[0].is_happening_now?.should be(false) }
      it { @events[1].is_happening_now?.should be(false) }
      it { @events[2].is_happening_now?.should be(true) }
      it { @events[3].is_happening_now?.should be(false) }
      it { @events[4].is_happening_now?.should be(false) }
    end

    describe "#future?" do
      it { @events[0].should_not be_future }
      it { @events[1].should_not be_future }
      it { @events[2].should_not be_future }
      it { @events[3].should be_future }
      it { @events[4].should be_future }
    end

  end

  describe "#get_formatted_hour" do
    skip
  end

  describe "social_networks attribute tokenization" do

    context "valid social network names" do
      let(:target) { FactoryGirl.create(:event, :social_networks => ['Facebook', 'Twitter']) }

      it { target.social_networks.should_not be_empty }
      it { target.social_networks.should include('Facebook') }
      it { target.social_networks.should include('Twitter') }
    end

    context "one invalid social network name" do
      let(:target) { FactoryGirl.create(:event, :social_networks => ['Facebok', 'Twitter']) }

      it { target.social_networks.should_not be_empty }
      skip { target.social_networks.should_not include('Facebok') }
      it { target.social_networks.should include('Twitter') }
    end

  end

  describe "coordinates are geocoded by address", :geocoding => true do
    let(:target) { FactoryGirl.create(:event, :address => 'Porto Alegre, Brazil', :longitude => nil, :latitude => nil) }

    it { target.longitude.should_not be_nil }
    it { target.latitude.should_not be_nil }
  end

  describe "clear coordinates when address is set to blank" do
    let(:target) { FactoryGirl.create(:event, :address => 'Porto Alegre, Brazil', :longitude => nil, :latitude => nil) }
    before(:each) {
      target.address = ''
      target.save
    }

    it { target.longitude.should be_nil }
    it { target.latitude.should be_nil }
  end

  describe "don't clear coordinates when other data is set to blank" do
    let(:target) { FactoryGirl.create(:event, :address => 'Porto Alegre, Brazil', :location => 'My House',
      :longitude => nil, :latitude => nil) }

    before(:each) {
      target.location = ''
      target.save
    }

    it { target.longitude.should_not be_nil }
    it { target.latitude.should_not be_nil }
  end

  describe "#to_ical" do
    let(:event) { FactoryGirl.create(:event, name: 'DTLaRAH', start_on: Time.now + 1.day, end_on: Time.new + 2.day) }

    it { event.to_ical.lines.first.should match('BEGIN:VCALENDAR') }
    it { event.to_ical.lines.last.should match('END:VCALENDAR') }
    it { event.to_ical.should match(/SUMMARY:#{event.name}/) }
    it { event.to_ical.should match(/URL:#{event.full_url}/) }

    # Doesnt work because the ical file is generate with random line breaks
    # it { event.to_ical.should match(/DESCRIPTION:#{event.description}/) }
  end

  describe "#is_registered?" do
    let(:target) { FactoryGirl.create(:event) }

    context "for an email" do
      context "when the email is not registered yet" do
        it { target.is_registered?("any@any.com").should be(false) }
      end

      context "when the email is already registered" do
        before {
          @participant = FactoryGirl.create(:participant, :event => target)
        }
        it { target.is_registered?(@participant.owner.email).should be(true) }
      end

      context "when the email is registered in another event" do
        before {
          second_event = FactoryGirl.create(:event)
          @participant = FactoryGirl.create(:participant, :event => second_event)
        }
        it { target.is_registered?(@participant.owner.email).should be(false) }
      end
    end

    context "for a user" do
      let(:user) { FactoryGirl.create(:user) }

      context "when the user is not registered yet" do
        it { target.is_registered?(user).should be(false) }
      end

      context "when the user is already registered" do
        before {
          @participant = FactoryGirl.create(:participant, :event => target, :owner => user)
        }
        it { target.is_registered?(user).should be(true) }
      end

      context "when the user is registered in another event" do
        before {
          second_event = FactoryGirl.create(:event)
          @participant = FactoryGirl.create(:participant, :event => second_event, :owner => user)
        }
        it { target.is_registered?(@participant.owner.email).should be(false) }
      end
    end
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:send_invitation, :register, :invite])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:event) }

    context "when it's an event of a user" do
      context "when it's the event creator" do
        let(:user) { target.owner }
        before { FactoryGirl.create(:participant, event: target, owner: user) }

        context "and the user is active" do
          it { should be_able_to_do_everything_to(target).except([:manage, :register]) }
        end

        context "and the user is disabled" do
          before { user.disable }
          it { should_not be_able_to_do_anything_to(target).except([:index]) }
        end

        context "and the user is not approved" do
          before { user.update_attributes(approved: false) }
          it { should_not be_able_to_do_anything_to(target).except([:index]) }
        end
      end

      context "when it's not the event creator" do
        let(:user) { FactoryGirl.create(:user) }
        it { should_not be_able_to_do_anything_to(target).except([:index, :show, :create, :new, :register]) }
      end
    end

    context "when it's an event of a" do
      let(:user) { FactoryGirl.create(:user) }

      context "public space" do
        let(:space) { FactoryGirl.create(:public_space) }
        let(:target) { FactoryGirl.create(:event, owner: space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:index, :show, :register]) }

          context "and he's already registered" do
            before { FactoryGirl.create(:participant, event: target, owner: user) }
            it { should_not be_able_to_do_anything_to(target).except([:index, :show]) }
          end
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { space.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:create, :destroy, :edit, :index, :new, :show, :update, :send_invitation, :register, :invite]) }
          end

          context "with the role 'User'" do
            before { space.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:create, :index, :new, :show, :register]) }
          end

          context "and he's already registered" do
            before {
              FactoryGirl.create(:participant, event: target, owner: user)
              space.add_member!(user, "Admin")
            }
            it { should be_able_to_do_everything_to(target).except([:manage, :register]) }
          end
        end

        context "that is disabled" do
          before { space.disable }
          it { should_not be_able_to_do_anything_to(target).except(:index) }
        end

        context "that is not approved" do
          before { space.update_attributes(approved: false) }
          it { should_not be_able_to_do_anything_to(target).except(:index) }
        end
      end

      context "private space" do
        let(:space) { FactoryGirl.create(:private_space) }
        let(:target) { FactoryGirl.create(:event, owner: space) }

        context "he is not a member of" do
          it { should_not be_able_to_do_anything_to(target).except([:index, :show]) }
        end

        context "he is a member of" do
          context "with the role 'Admin'" do
            before { space.add_member!(user, "Admin") }
            it { should_not be_able_to_do_anything_to(target).except([:create, :destroy, :edit, :index, :new, :show, :update, :send_invitation, :register, :invite]) }
          end

          context "with the role 'User'" do
            before { space.add_member!(user, "User") }
            it { should_not be_able_to_do_anything_to(target).except([:create, :index, :new, :show, :register]) }
          end

          context "and he's already registered" do
            before {
              FactoryGirl.create(:participant, event: target, owner: user)
              space.add_member!(user, "Admin")
            }
            it { should be_able_to_do_everything_to(target).except([:manage, :register]) }
          end
        end

        context "that is disabled" do
          before { space.disable }
          it { should_not be_able_to_do_anything_to(target).except(:index) }
        end

        context "that is not approved" do
          before { space.update_attributes(approved: false) }
          it { should_not be_able_to_do_anything_to(target).except(:index) }
        end
      end
    end
  end

  describe "spaces module" do
    let(:space) { FactoryGirl.create(:space) }
    let(:user) { FactoryGirl.create(:superuser) }
    let!(:today) { Time.now }
    before(:each) do
      @events = [
        FactoryGirl.create(:event, owner: FactoryGirl.create(:space, public: true), start_on: today + 1.day, end_on: today + 2.day),
        FactoryGirl.create(:event, owner: FactoryGirl.create(:space, public: true), start_on: today + 1.day, end_on: today + 2.day),
        FactoryGirl.create(:event, owner: FactoryGirl.create(:space, public: true), start_on: today + 1.day, end_on: today + 2.day),
        FactoryGirl.create(:event, owner: FactoryGirl.create(:user), start_on: today + 1.day, end_on: today + 2.day),
        FactoryGirl.create(:event, owner: FactoryGirl.create(:user), start_on: today + 1.day, end_on: today + 2.day)
      ]
    end
    context "disabled" do
      before(:each) {
        Site.current.update_attribute(:spaces_enabled, false)
        login_as(user)
      }
      it { Event.upcoming.count.should eq(2) }
    end

    context "enabled" do
      before(:each) {
        Site.current.update_attribute(:spaces_enabled, true)
        login_as(user)
      }
      it { Event.upcoming.count.should eq(5) }
    end
  end

  skip "abilities (using permissions, space admins, event organizers)"
end
