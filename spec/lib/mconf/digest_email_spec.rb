# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::DigestEmail do

  subject { Mconf::DigestEmail }

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
        @now = Time.parse("Sun, 10 Jan 2012 00:00:00 +0000")
        @from = Time.parse("Sun, 09 Jan 2012 00:00:00 +0000")
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
        @now = Time.parse("Sun, 10 Jan 2012 00:00:00 +0000")
        @from = Time.parse("Sun, 03 Jan 2012 00:00:00 +0000")
        Time.stub(:now) { @now }
        subject.should_receive(:send_digest).twice.with(anything, @from, @now)
        subject.send_weekly_digest
      end
    end
  end

  describe ".get_activity" do
    let(:user) { FactoryGirl.create(:user) }
    let(:now) { Time.now }
    let(:date_start) { now - 1.day }
    let(:date_end) { now }
    let(:space) { FactoryGirl.create(:space) }
    let(:call_get_activity) {
      @posts, @news, @attachments, @events, @inbox = subject.get_activity(user, date_start, date_end)
    }
    before do
      # add the user to the space
      FactoryGirl.create(:admin_performance, :agent => user, :stage => space)
      # create some extra data that should not be returned
      other_space = FactoryGirl.create(:space)
      FactoryGirl.create(:event, :space => other_space)
      FactoryGirl.create(:post, :space => other_space)
      FactoryGirl.create(:news, :space => other_space)
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
    end

    context "returns empty arrays if nothing is found" do
      before(:each) { call_get_activity }
      it { @posts.should == [] }
      it { @attachments.should == [] }
      it { @news.should == [] }
      it { @events.should == [] }
      it { @inbox.should == [] }
    end

    context "returns the latest posts in the user's spaces" do
      before { create_default_objects(:post) }
      before(:each) { call_get_activity }
      it { @expected.should == @posts }
    end

    context "returns the latest news in the user's spaces" do
      before { create_default_objects(:news) }
      before(:each) { call_get_activity }
      it { @expected.should == @news }
    end

    context "returns the latest attachments in the user's spaces" do
      before { create_default_objects(:attachment) }
      before(:each) { call_get_activity }
      it { @expected.should == @attachments }
    end

    context "returns the latest events in the user's spaces" do
      before do
        # events out of the search range
        FactoryGirl.create(:event, :space => space, :start_date => date_start - 1.hour, :end_date => date_start - 1.second)
        FactoryGirl.create(:event, :space => space, :start_date => date_end + 1.second, :end_date => date_end + 1.hour)
        # events entirely within range
        @expected = []
        @expected << FactoryGirl.create(:event, :space => space, :start_date => date_start, :end_date => date_start + 1.hour)
        @expected << FactoryGirl.create(:event, :space => space, :start_date => date_start + 1.hour, :end_date => date_start + 2.hours)
        @expected << FactoryGirl.create(:event, :space => space, :start_date => date_end - 1.hour, :end_date => date_end)
        # events with only start or end within range
        @expected << FactoryGirl.create(:event, :space => space, :start_date => date_start - 1.hour, :end_date => date_start + 1.hour)
        @expected << FactoryGirl.create(:event, :space => space, :start_date => date_end - 1.hour, :end_date => date_end + 1.hour)
        @expected.sort_by!{ |p| p.updated_at }.reverse!
      end
      before(:each) { call_get_activity }
      it { @expected.should == @events }
    end

    context "returns the unread messages in the inbox" do
      before do
        sender = FactoryGirl.create(:user)
        # unread messages for the target user
        @expected = []
        @expected << FactoryGirl.create(:private_message, :receiver => user, :sender => sender)
        @expected << FactoryGirl.create(:private_message, :receiver => user, :sender => sender)
        @expected.sort_by!{ |p| p.updated_at }.reverse!
        # read message
        FactoryGirl.create(:private_message, :receiver => user, :sender => sender, :checked => true)
        # message to another user
        FactoryGirl.create(:private_message, :receiver => FactoryGirl.create(:user), :sender => sender)
      end
      before(:each) { call_get_activity }
      it { @expected.should == @inbox }
    end
  end

  describe ".send_digest" do
    let(:user) { FactoryGirl.create(:user) }
    let(:now) { Time.now }
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
        }.not_to change{ ActionMailer::Base.deliveries.length}.by(1)
      }
    end

    context "sends the email" do
      let(:space) { FactoryGirl.create(:space) }

      before do
        # add the user to the space
        FactoryGirl.create(:admin_performance, :agent => user, :stage => space)
        # create the data to be returned
        @posts = [ FactoryGirl.create(:post, :space => space, :updated_at => date_start) ]
        @news = [ FactoryGirl.create(:news, :space => space, :updated_at => date_start) ]
        @attachments = [ FactoryGirl.create(:attachment, :space => space, :updated_at => date_start) ]
        @events = [ FactoryGirl.create(:event, :space => space, :start_date => date_start,
                                   :end_date => date_start + 1.hour, :author => user) ]
        @inbox = [ FactoryGirl.create(:private_message, :receiver => user, :sender => FactoryGirl.create(:user)) ]

        subject.should_receive(:get_activity).with(user, date_start, date_end).
          and_return([ @posts, @news, @attachments, @events, @inbox ])

        delayer = mock()
        Notifier.stub(:delay).and_return(delayer)
        delayer.should_receive(:digest_email).
          with(user, @posts, @news, @attachments, @events, @inbox)
      end
      it {
        subject.send_digest(user, date_start, date_end)
      }
    end
  end

end
