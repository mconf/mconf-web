# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

def post_to_space title, text
  visit new_space_post_path(space)
  fill_in 'post[title]', with: title
  fill_in 'post[text]', with: text
  click_button t('_other.send')
end

feature 'Member posts to wall', with_js: true do

  skip 'a member visiting posts page' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space_with_associations) }

    before(:each) {
      space.add_member!(user)
      login_as(user, :scope => :user)
      # TODO: open via xhr, it's a modal
      visit space_posts_path(space)
    }

    it { current_path.should eq(space_posts_path(space)) }
    it { page.find('#space-posts').should have_css('.thread-post', :count => 0) }

    context 'post valid data to page' do
      before { post_to_space 'my title', 'my text' }

      it { has_success_message t('flash.posts.create.notice') }
      it { page.should have_content('my title') }
      it { page.should have_content('my text') }
      it { page.find('#space-posts').should have_css('.thread-post', :count => 1) }
    end
  end

  skip 'an annonymous user'
  skip 'not a member of the space'
end
