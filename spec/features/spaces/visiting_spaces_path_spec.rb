# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

describe 'User accesses spaces index' do
  subject { page }

  context 'showing as' do
    let!(:default_logo84x64) { '/assets/default_logos/84x64/space.png' }
    let!(:space) { FactoryGirl.create(:space_with_associations, public: true) }
    before { space.update_attributes(:tag_list => ["a tag"]) }

    context 'list view' do
      context 'with default logo' do
        before { visit spaces_path }

        it { should have_css '.space-container', count: 1 }
        it { should have_content space.name }
        it { should have_content space.tag_list.first }
        it { should have_content space.description }
        it { should have_css '.logo-space.logo-initials', text: space.initials }
      end

      context 'and with valid logo' do
        before {
          space.update_attributes(:logo_image => File.open('spec/fixtures/files/test-logo.png'))
          visit spaces_path
        }

        it { should have_image "logo84x64_#{space.logo_image.file.filename}" }
      end
    end

    context "filtering tags by \"a tag\"" do
      before { visit spaces_path(tag: space.tag_list.first) }
      it { should have_content space.name }
      it { should have_content space.tag_list.first }
    end

    context "filtering tags by \"missing tag\"" do
      before { visit spaces_path(tag: 'missing tag') }
      it { should_not have_content space.name }
      it { should_not have_content space.tag_list.first }
    end
  end

  context 'anonymously' do
    let!(:space) { FactoryGirl.create(:space_with_associations) }

    context 'all spaces' do
      before { visit spaces_path }
      it { should have_css '.space-container', :count => 1 }
      it { should_not have_css '#show-spaces-mine' }
    end

    context 'my spaces' do
      before { # user can only access this via URL, but shouldn't fail
        visit spaces_path(:my_spaces => true)
      }
      it { should have_css '.space-container', :count => 0 }
      it { should_not have_css '#show-spaces-mine' }
      it { should_not_be_500_page }
    end
  end

  context 'as a normal user with spaces' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations) }
    let(:space2) { FactoryGirl.create(:space_with_associations) }
    before {
      space.add_member!(user)
      space2
      login_as(user, :scope => :user)
      visit spaces_path
    }

    context 'all spaces' do
      it { should have_link t('spaces.index.create_new_space'), :href => new_space_path }
      it { should have_content space.name }
      it { should have_content space2.name }
      it { should have_css '#show-spaces-mine' }
      it { should have_css '.space-container', :count => 2 }
    end

    # TODO: Skipping because with_js is not working properly yet
    skip 'my spaces', with_js: true do
      before { find('#show-spaces-mine').click } # click the 'My spaces' button
      it { should have_link t('spaces.index.create_new_space'), :href => new_space_path }
      it { should have_content space.name }
      it { should_not have_content space2.name }
      it { should have_css '#show-spaces-mine' }
      it { should have_css '.space-container', :count => 1 }
    end
  end

  context 'as a normal user with no spaces' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations) }
    before {
      space
      login_as(user, :scope => :user)
    }

    context 'all spaces' do
      before { visit spaces_path }
      it { should have_content space.name }
      it { should have_css '#show-spaces-mine' }
      it { should have_css '.space-container', :count => 1 }
    end

    # TODO: Skipping because with_js is not working properly yet
    skip 'my spaces', with_js: true do
      before {
        visit spaces_path
        find('#show-spaces-mine').click # click the 'My spaces' button
      }
      it { should have_css '#show-spaces-mine' }
      it { should have_css '.space-container', :count => 0 }
    end
  end

  context 'spaces module is disabled' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations) }
    before {
      Site.current.update_attribute(:spaces_enabled, false)
      space
      login_as(user, :scope => :user)
    }

    context 'the page will not render (404)' do
      before { visit spaces_path }
      it { should_not have_content space.name }
      it { should_not have_css '#show-spaces-mine' }
      it { should_not have_css '.space-container', :count => 1 }
      it { page.status_code.should == 404 }
    end
  end

end

