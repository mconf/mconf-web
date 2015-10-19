# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'User accesses an URL of a user that' do

  context 'does exist' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    subject { page }

    it { should have_title(user.name) }
    it { should have_content(user.name) }
    it { page.status_code.should == 200 }
  end

  context 'does not exist' do
    before { visit user_path(:id => 'nonexistent') }
    subject { page }

    it { should have_title(t('error.e404.title')) }
    it { should have_content(t('error.e404.title')) }
    it { should have_content(t('error.e404.description', :url => user_path(:id => 'nonexistent'))) }
    it { page.status_code.should == 404 }
  end

end
