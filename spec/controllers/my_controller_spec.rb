# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe MyController do
  render_views

  it "#show"
  it "#activity"
  it "#rooms"

  describe "#room_edit" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { login_as(user) }

    context "html request" do
      before(:each) { get :room_edit }
      it { should render_template(:room_edit) }
      it { should render_with_layout("application") }
      it { should assign_to(:room).with(user.bigbluebutton_room) }
      it "calls @room.get_meeting_info"
      it { should assign_to(:redirect_to).with(home_path) }
    end

    context "xhr request" do
      before(:each) { xhr :get, :room_edit }
      it { should render_template(:room_edit) }
      it { should_not render_with_layout }
    end
  end

  describe "#room_recordings" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) { login_as(user) }

    context "html full request" do
      before(:each) { get :room_recordings }
      it { should render_template(:room_recordings) }
      it { should render_with_layout("no_sidebar") }
      it { should assign_to(:room).with(user.bigbluebutton_room) }
      it "calls @room.get_meeting_info"

      context "assigns @recordings" do
        context "doesn't include recordings from rooms of other owners" do
          before :each do
            FactoryGirl.create(:bigbluebutton_recording, :room => FactoryGirl.create(:bigbluebutton_room), :published => true)
          end
          it { should assign_to(:recordings).with([]) }
        end

        context "doesn't include recordings that are not published" do
          before :each do
            FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => false)
          end
          it { should assign_to(:recordings).with([]) }
        end

        context "includes recordings that are not available" do
          before :each do
            @recording = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                            :available => false)
          end
          it { should assign_to(:recordings).with([@recording]) }
        end

        context "order recordings by end_time DESC" do
          before :each do
            r1 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                    :end_time => DateTime.now)
            r2 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                    :end_time => DateTime.now - 2.days)
            r3 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                    :end_time => DateTime.now - 1.hour)
            @expected_recordings = [r1, r3, r2]
          end
          it { should assign_to(:recordings).with(@expected_recordings) }
        end
      end
    end

    context "if params[:limit] is set" do
      describe "limits the number of recordings assigned to @recordings" do
        before :each do
          @r1 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now)
          @r2 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 1.hour)
          @r3 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 2.hours)
          @r4 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 3.hours)
          @r5 = FactoryGirl.create(:bigbluebutton_recording, :room => user.bigbluebutton_room, :published => true,
                                   :end_time => DateTime.now - 4.hours)
        end
        before(:each) { get :room_recordings, :limit => 3 }
        it { assigns(:recordings).count.should be(3) }
        it { assigns(:recordings).should include(@r1) }
        it { assigns(:recordings).should include(@r2) }
        it { assigns(:recordings).should include(@r3) }
      end
    end

    context "if params[:partial] is set" do
      before(:each) { get :room_recordings, :partial => true }
      it { should render_template(:room_recordings) }
      it { should_not render_with_layout }
    end
  end

end
