# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Show user activity' do

  context 'to an annonymous user' do
    before { visit my_activity_path }

    it { current_path.should eq(new_user_session_path) }
    it { have_failed_message }
  end

  context 'on user without activities home page' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      login_as(user, :scope => :user)
      visit my_activity_path
    end

    it { current_path.should eq(my_activity_path) }
    it { page.should have_selector('#users-recent-activity .single-activity', :count => 0) }
  end

  context 'on user with activities home page' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations) }
    before do
      space.add_member!(user)
      login_as(user, :scope => :user)
      # TODO, test it via controller doing those actions
      space.new_activity :create, user
      space.new_activity :update, user
      visit my_activity_path
    end

    it { current_path.should eq(my_activity_path) }

    context 'inside #users-recent-activity' do
      subject { page.find('#users-recent-activity') }
      it { should have_selector('.single-activity', :count => 2) }
      it { should have_selector('.space', :count => 2) }
      it { should have_content(user.name, :count => 2) }
      it { should have_content(space.name, :count => 2) }
      it { should have_content(I18n.t('activities.space.create_html'), :count => 1) }
      it { should have_content(I18n.t('activities.space.update_html'), :count => 1) }
    end
  end

  # context "activities with deleted trackable" do
  #   let(:user) { FactoryGirl.create(:user) }

  #   [:attachment, :bigbluebutton_meeting, :event, :join_request, :participant, :post, :space].each do |model|
  #     context "Recent activity for a deleted #{model} trackable" do
  #       let(:target) { FactoryGirl.create(model) }
  #       let(:activity) { RecentActivity.create(trackable: model, recipient: user, key: "#{model.class_name}.create") }

  #       it { page.should have_content() }
  #       it { page.should have_content() }
  #     end
  #   end
  # end

  context "activities with deleted recipient" do
    # attachment bigbluebutton_meeting event join_request participant post  space

  end

  context "activities with deleted owners" do
    # attachment bigbluebutton_meeting event join_request participant post  space

    # No spaces?

  end

  context 'activities module enabled false' do
    let(:user) { FactoryGirl.create(:superuser) }
    before(:each) {
      Site.current.update_attributes(activities_enabled: false)
      login_as(user)
      visit my_activity_path
    }

    it { page.status_code.should == 404 }
  end


end
