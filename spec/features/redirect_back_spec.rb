# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2016 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

feature 'Visitor logs in and is redirected back to a sane URL' do

  before(:each) {
    @user = FactoryGirl.create(:user, :username => 'user-1', :password => 'password')
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

  context 'when the referer URL uses a different protocol' do
    before {
      Site.current.update_attributes(domain: "localhost", ssl: false) # HTTP
      page.driver.header 'Referer', "https://localhost" # HTTPS

      sign_in_with @user.email, @user.password
      visit edit_user_path(@user)
      visit login_path
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'when the referer URL uses a different port' do
    before {
      Site.current.update_attributes(domain: "localhost:3000") # HTTP
      page.driver.header 'Referer', "http://localhost:5000" # HTTPS

      sign_in_with @user.email, @user.password
      visit edit_user_path(@user)
      visit login_path
    }

    it { current_path.should eq(my_home_path) }
  end

  context 'when return_to is set' do
    before {
      # valid referer, to make sure it would redirect to the previous
      # path if return_to wasn't set
      Site.current.update_attributes(domain: "localhost:3000")
      page.driver.header 'Referer', "http://localhost:3000"

      sign_in_with @user.email, @user.password
    }

    context "to a valid path" do
      before {
        visit spaces_path
        visit login_path(return_to: "/spaces")
      }

      it { current_path.should eq(spaces_path) }
    end

    context "to a path that is not redirectable" do
      before {
        visit spaces_path
        visit login_path(return_to: shibboleth_info_path)
      }

      it { current_path.should eq(spaces_path) }
    end

    context "to an external path" do
      before {
        visit spaces_path
        visit login_path(return_to: "http://google.com")
      }

      it { current_path.should eq(spaces_path) }
    end

    context "to a full url" do
      before {
        visit spaces_path
        visit login_path(return_to: "http://localhost:3000/spaces")
      }

      it { current_path.should eq(spaces_path) }
    end

    context "to a blank url" do
      before {
        visit spaces_path
        visit login_path(return_to: "  ")
      }

      it { current_path.should eq(spaces_path) }
    end

  end

end
