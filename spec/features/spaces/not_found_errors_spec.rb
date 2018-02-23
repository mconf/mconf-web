# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

# For sanitize helpers
include ActionView::Helpers::SanitizeHelper

feature 'User accesses an URL of a space that' do

  context 'does exist' do
    let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
    before { visit space_path(space) }
    subject { page }

    it { should have_title(space.name) }
    it { should have_content(space.name) }
    it { page.status_code.should == 200 }
  end

  context 'does not exist' do
    before { visit space_path(:id => 'nonexistent') }
    subject { page }

    it { should have_title(t('error.e404.title')) }
    it { should have_content(t('error.e404.title')) }
    it { should have_content(
      strip_tags(t('spaces.error.not_found', :slug => 'nonexistent', :path => spaces_path))
      )
    }
    it { should have_link('', :href => spaces_path) }
    it { page.status_code.should == 404 }
  end

end
