# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

#
# Currently the user visits each of the spaces' tabs and we check to see if it worked
# and the tab is selected. We could test for extra actions in each of these pages too, e.g, 'can an event be created?'
#
feature 'User is' do

  context 'a logged out user visiting a public space' do
    let(:space) { FactoryGirl.create(:space_with_associations, :repository => true, public: true) }

    scenario 'on home page' do
      visit space_path(space)
      save_page

      within('#webconference-start') do
        page.all('.with-tooltip').count.should eql(1)
        page.all('a').count.should eql(2)
      end

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.home'))
      end
    end

    scenario 'on posts page' do
      visit space_posts_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.posts'))
      end
    end

    scenario 'on attachments page' do
      visit space_attachments_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.repository'))
      end
    end

    scenario 'on events page' do
      visit space_events_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.events'))
      end
    end

    scenario 'on users page' do
      visit space_users_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.users'))
      end
    end

    scenario 'on web conference page' do
      visit webconference_space_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.webconference'))
      end
    end

  end

  context 'a non member visiting a space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations, :repository => true, public: true) }

    before(:each) { login_as(user, :scope => :user) }

    scenario 'on home page' do
      visit space_path(space)

      within('#webconference-start') do
        page.all('.with-tooltip').count.should eql(1)
        page.all('a').count.should eql(2)
      end

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.home'))
      end
    end

    scenario 'on posts page' do
      visit space_posts_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.posts'))
      end
    end

    scenario 'on attachments page' do
      visit space_attachments_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.repository'))
      end
    end

    scenario 'on events page' do
      visit space_events_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.events'))
      end
    end

    scenario 'on users page' do
      visit space_users_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.users'))
      end
    end

    scenario 'on web conference page' do
      visit webconference_space_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.webconference'))
      end
    end

  end

  context 'a member of the space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations, :repository => true) }

    before(:each) {
      space.add_member!(user)
      login_as(user, :scope => :user)
    }

    scenario 'on home page' do
      visit space_path(space)

      within('#webconference-start') do
        page.all('.with_tooltip').count.should eql(0)
        page.all('a').count.should eql(3)
      end

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.home'))
      end
    end

    scenario 'on posts page' do
      visit space_posts_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.posts'))
      end
    end

    scenario 'on attachments page' do
      visit space_attachments_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.repository'))
      end
    end

    scenario 'on events page' do
      visit space_events_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.events'))
      end
    end

    scenario 'on users page' do
      visit space_users_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.users'))
      end
    end

    scenario 'on web conference page' do
      visit webconference_space_path(space)

      within('#sidebar-menu ul li.active') do
        expect(page).to have_link(I18n.t('spaces.sidebar.webconference'))
      end
    end
  end

  context 'an admin of the space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations, repository: true) }

    before(:each) {
      space.add_member!(user, "Admin")
      login_as(user, :scope => :user)
    }

    scenario 'on home page' do
      visit space_path(space)

      within('#webconference-start') do
        page.all('.with_tooltip').count.should eql(0)
        page.all('a').count.should eql(4)
      end
    end

    scenario 'on edit page' do
      visit edit_space_path(space)
    end

  end

end
