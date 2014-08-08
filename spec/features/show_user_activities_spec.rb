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
    let(:space) { FactoryGirl.create(:space) }
    before do
      space.add_member!(user)
      login_as(user, :scope => :user)
      # TODO, test it via controller doing those actions
      space.new_activity 'create', user
      space.new_activity 'update', user
      visit my_activity_path
    end

    it { current_path.should eq(my_activity_path) }

    context 'inside #users-recent-activity' do
      subject { page.find('#users-recent-activity') }
      it { should have_selector('.single-activity', :count => 2) }
      it { should have_selector('.space', :count => 2) }
      it { should have_content(user._full_name, :count => 2) }
      it { should have_content(space.name, :count => 2) }
      it { should have_content(I18n.t('activities.space.create_html'), :count => 1) }
      it { should have_content(I18n.t('activities.space.update_html'), :count => 1) }
    end
  end

end