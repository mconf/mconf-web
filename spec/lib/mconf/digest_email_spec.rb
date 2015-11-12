# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::DigestEmail do

  subject { Mconf::DigestEmail }
  before(:each, :events => true) do
    Site.current.update_attributes(:events_enabled => true)
  end

  describe ".send_daily_digest" do
    before do
      # users that will NOT receive a digest
      FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_NEVER)
      FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_WEEKLY)
      # users that will receive a daily digest
      @users = [ FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_DAILY),
                 FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_DAILY) ]
    end

    context "calls send_digest" do
      it "only for the users with User::RECEIVE_DIGEST_DAILY" do
        subject.should_receive(:send_digest).with(@users[0], anything, anything)
        subject.should_receive(:send_digest).with(@users[1], anything, anything)
        subject.send_daily_digest
      end

      it "with the correct start and end dates" do
        @now = Time.zone.parse("Sun, 10 Jan 2012 00:00:00 +0000")
        @from = Time.zone.parse("Sun, 09 Jan 2012 00:00:00 +0000")
        Time.stub(:now) { @now }
        subject.should_receive(:send_digest).twice.with(anything, @from, @now)
        subject.send_daily_digest
      end
    end
  end

  describe ".send_weekly_digest" do
    before do
      # users that will NOT receive a digest
      FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_NEVER)
      FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_DAILY)
      # users that will receive a daily digest
      @users = [ FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_WEEKLY),
                 FactoryGirl.create(:user, :receive_digest => User::RECEIVE_DIGEST_WEEKLY) ]
    end

    context "calls send_digest" do
      it "only for the users with User::RECEIVE_DIGEST_WEEKLY" do
        subject.should_receive(:send_digest).with(@users[0], anything, anything)
        subject.should_receive(:send_digest).with(@users[1], anything, anything)
        subject.send_weekly_digest
      end

      it "with the correct start and end dates" do
        @now = Time.zone.parse("Sun, 10 Jan 2012 00:00:00 +0000")
        @from = Time.zone.parse("Sun, 03 Jan 2012 00:00:00 +0000")
        Time.stub(:now) { @now }
        subject.should_receive(:send_digest).twice.with(anything, @from, @now)
        subject.send_weekly_digest
      end
    end
  end

  describe ".get_activity" do
    let(:user) { FactoryGirl.create(:user) }
    let(:now) { Time.zone.now }
    let(:date_start) { now - 1.day }
    let(:date_end) { now }
    let(:space) { FactoryGirl.create(:space) }
    let(:call_get_activity) {
      @posts, @attachments, @events = subject.get_activity(user, date_start, date_end)
    }
    before do
      space.add_member!(user)
      # create some extra data that should not be returned
      other_space = FactoryGirl.create(:space)
      FactoryGirl.create(:event, :time_zone => Time.zone.name, :owner => other_space)
      FactoryGirl.create(:post, :space => other_space)
      FactoryGirl.create(:attachment, :space => other_space)
    end

    def create_default_objects(factory)
      # objects (barely) out of range
      FactoryGirl.create(factory, :space => space, :updated_at => date_start - 1.second)
      FactoryGirl.create(factory, :space => space, :updated_at => date_end + 1.second)
      # objects within range
      @expected = []
      @expected << FactoryGirl.create(factory, :space => space, :updated_at => date_start)
      @expected << FactoryGirl.create(factory, :space => space, :updated_at => date_start + 1.hour)
      @expected << FactoryGirl.create(factory, :space => space, :updated_at => date_end)
      @expected.sort_by!{ |p| p.updated_at }.reverse!
      @expected = @expected.map { |x| x.id }
    end

    context "returns empty arrays if nothing is found" do
      before(:each) { call_get_activity }
      it { @posts.should == [] }
      it { @attachments.should == [] }
      it { @events.should == [] }
    end

    context "returns the latest posts in the user's spaces" do
      before { create_default_objects(:post) }
      before(:each) { call_get_activity }
      it { @expected.should == @posts }
    end

    context "returns the latest attachments in the user's spaces" do
      before { create_default_objects(:attachment) }
      before(:each) { call_get_activity }
      it { @expected.should == @attachments }
    end

    context "returns the latest events in the user's spaces", :events => true do
      before do
        # events out of the search range
        FactoryGirl.create(:event, :owner => space, :time_zone => Time.zone.name, :start_on => date_start - 1.hour, :end_on => date_start - 1.second)
        FactoryGirl.create(:event, :owner => space, :time_zone => Time.zone.name, :start_on => date_end + 1.minute, :end_on => date_end + 1.hour)

        # Explicit time for the event to be updated
        start_time = Time.now

        # events entirely within range
        @expected = []
        @expected << FactoryGirl.create(:event, :time_zone => Time.zone.name, :updated_at => start_time, :owner => space, :start_on => date_start, :end_on => date_start + 1.hour)
        @expected << FactoryGirl.create(:event, :time_zone => Time.zone.name, :updated_at => start_time + 1.minute, :owner => space, :start_on => date_start + 1.hour, :end_on => date_start + 2.hours)
        @expected << FactoryGirl.create(:event, :time_zone => Time.zone.name, :updated_at => start_time + 2.minute, :owner => space, :start_on => date_end - 1.hour, :end_on => date_end)
        # events with only start or end within range
        @expected << FactoryGirl.create(:event, :time_zone => Time.zone.name, :updated_at => start_time + 3.minute, :owner => space, :start_on => date_start - 1.hour, :end_on => date_start + 1.hour)
        @expected << FactoryGirl.create(:event, :time_zone => Time.zone.name, :updated_at => start_time + 4.minute, :owner => space, :start_on => date_end - 1.hour, :end_on => date_end + 1.hour)
        @expected.sort_by!{ |p| p.updated_at }.reverse!
        @expected = @expected.map { |x| x.id }
      end
      before(:each) { call_get_activity }
      it { @expected.should == @events }
    end

  end

  describe ".send_digest" do
    let(:user) { FactoryGirl.create(:user) }
    let(:now) { Time.zone.now }
    let(:date_start) { now - 1.day }
    let(:date_end) { now }

    context "calls .get_activity" do
      before do
        subject.should_receive(:get_activity).with(user, date_start, date_end).
          and_return([ [], [], [], [], [] ])
      end
      it { subject.send_digest(user, date_start, date_end) }
    end

    context "doesn't send the email if there's no recent activity" do
      before do
        subject.should_receive(:get_activity).with(user, date_start, date_end).
          and_return([ [], [], [], [], [] ])
      end
      it {
        expect {
          subject.send_digest(user, date_start, date_end)
        }.not_to change{ ActionMailer::Base.deliveries.length}
      }
    end

    context "sends the email" do
      let(:user) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:space) }

      before do
        ResqueSpec.reset!

        # create the data to be returned
        @posts = [ FactoryGirl.create(:post, :space => space, :updated_at => date_start).id,
                   FactoryGirl.create(:post, :space => space, :updated_at => date_start).id ]
        @attachments = [ FactoryGirl.create(:attachment, :space => space, :updated_at => date_start).id,
                         FactoryGirl.create(:attachment, :space => space, :updated_at => date_start).id ]
        @events = [
          FactoryGirl.create(:event, :time_zone => Time.zone.name, :owner => space, :start_on => date_start, :end_on => date_start + 1.hour).id,
          FactoryGirl.create(:event, :time_zone => Time.zone.name, :owner => space, :start_on => date_start, :end_on => date_start + 1.hour).id
        ]

        subject.should_receive(:get_activity).with(user, date_start, date_end).
          and_return([ @posts, @attachments, @events])
      end

      before(:each) { subject.send_digest(user, date_start, date_end) }
      it { ApplicationMailer.should have_queue_size_of(1) }
      it { ApplicationMailer.should have_queued(:digest_email, user.id, @posts, @attachments, @events, @inbox) }
    end
  end

end
