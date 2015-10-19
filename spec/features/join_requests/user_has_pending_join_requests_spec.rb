# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "User's pending join requests" do

  context 'has one pending invitation' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:jr) { FactoryGirl.create(:space_join_request, :candidate => user, :request_type => JoinRequest::TYPES[:invite]) }

    before(:each) {
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
