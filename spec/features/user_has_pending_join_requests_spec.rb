require 'spec_helper'
require 'support/feature_helpers'

feature 'User\'s pending join requests' do

  context 'has one pending invitation' do

    let(:user) { FactoryGirl.create(:user, :username => 'user', :password => 'password') }
    let(:jr) { FactoryGirl.create(:space_join_request, :candidate => user, :request_type => 'invite') }

    before(:each) {
      jr
      login_as(user, :scope => :user)
    }

    scenario 'on my_home_path' do
      visit my_home_path

      within('#user-pending-join-requests') do
        expect(page).to have_content('1')

        expect(page).to have_link(jr.group.name, :href => space_path(jr.group))
        expect(page).to have_link(I18n.t('spaces.space_thumbnail.reply_invitation'), :href => space_join_request_path(jr.group, jr))
      end
    end

    context 'on join request page' do
      skip
    end
  end

  scenario 'has 2 pending invitations' do
    skip
  end

  scenario 'has one pending join request' do
    skip
  end

  scenario 'has 2 pending join requests' do
    skip
  end

  scenario 'has no pending join requests' do
    skip
  end

end
