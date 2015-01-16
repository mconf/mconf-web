require 'spec_helper'
require 'support/feature_helpers'

feature 'User is' do

  context 'a member of the space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space, :repository => true) }

    before(:each) {
      space.add_member!(user)
      login_as(user, :scope => :user)
    }

    scenario 'on home page' do
      visit space_path(space)

      within('#page-menu ul li.selected') do
        expect(page).to have_link(I18n.t('spaces.menu.home'))
      end
    end

    scenario 'on posts page' do
      visit space_posts_path(space)

      within('#page-menu ul li.selected') do
        expect(page).to have_link(I18n.t('spaces.menu.posts'))
      end
    end

    scenario 'on attachments page' do
      visit space_attachments_path(space)

      within('#page-menu ul li.selected') do
        expect(page).to have_link(I18n.t('spaces.menu.repository'))
      end
    end

    scenario 'on events page' do
      visit space_events_path(space)

      within('#page-menu ul li.selected') do
        expect(page).to have_link(I18n.t('spaces.menu.events'))
      end
    end

    scenario 'on users page' do
      visit space_users_path(space)

      within('#page-menu ul li.selected') do
        expect(page).to have_link(I18n.t('spaces.menu.users'))
      end
    end

    scenario 'on web conference page' do
      visit webconference_space_path(space)

      within('#page-menu ul li.selected') do
        expect(page).to have_link(I18n.t('spaces.menu.webconference'))
      end
    end
  end

  context 'an admin of the space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space, :repository => true) }

    before(:each) {
      space.add_member!(user)
      login_as(user, :scope => :user)
    }

    scenario 'on edit page' do
      visit edit_space_path(space)
    end

  end

end