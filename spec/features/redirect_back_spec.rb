# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

feature 'Visitor logs in and is redirected back to a sane URL' do

  before(:each) {
    @user = FactoryGirl.create(:user, :username => 'user', :password => 'password')
  }

  context 'when referer is blank' do
    let(:referer) { nil }

    before {
      page.driver.header 'Referer', referer

      visit login_path
      sign_in_with @user.email, @user.password
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'when referer is outside of the application' do
    let(:referer) { 'https://email-server.com/my-email' }

    before {
      page.driver.header 'Referer', referer

      sign_in_with @user.email, @user.password
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'when is already logged in and comes from an outside' do
    let(:referer) { 'https://email-server.com/my-email' }

    before {
      sign_in_with @user.email, @user.password

      page.driver.header 'Referer', referer

      visit login_path
    }

    it { current_path.should eq(my_home_path) }

  end

  context 'when referer is blank and user was browsing in another tab' do
    let(:referer) { nil }

    before {
      sign_in_with @user.email, @user.password

      visit spaces_path

      # Clear referer to simulate coming from another tab
      page.driver.header 'Referer', nil

      visit login_path
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'when to was set to /feedback/webconf because of a meeting end and user comes from another tab' do
    before {
      Site.current.update_attributes(feedback_url: 'https://feedback-place.fun')
      sign_in_with @user.email, @user.password

      visit webconf_feedback_index_path

      # Clear referer to simulate coming from another tab
      page.driver.header 'Referer', nil

      visit login_path
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'considers the protocols when comparing local host with the external host' do
    before {
      Site.current.update_attributes(domain: "localhost", ssl: false) # HTTP
      page.driver.header 'Referer', "https://localhost" # HTTPS

      sign_in_with @user.email, @user.password
      visit edit_user_path(@user)
      visit login_path
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'considers the ports when comparing local host with the external host' do
    before {
      Site.current.update_attributes(domain: "localhost:3000") # HTTP
      page.driver.header 'Referer', "http://localhost:5000" # HTTPS

      sign_in_with @user.email, @user.password
      visit edit_user_path(@user)
      visit login_path
    }

    it { current_path.should eq(my_home_path) }
  end

end
