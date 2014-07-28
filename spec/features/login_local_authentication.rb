require 'spec_helper'
require 'support/feature_helpers'

feature 'Disable local authentication' do
  before(:each) { FactoryGirl.create(:user, :username => 'user', :password => 'password') }
 
  context 'local_authenticaton is enabled' do
    before { Site.current.update_attributes(:disable_local_auth => false) }
    before(:each) {
      #ApplicationController.any_instance.stub(:referer).and_return('http://example1.com')
      request = double('request')
      allow(request).to receive(:referer).and_return('http://example1.com')
    }

    scenario 'from /login' do
      visit login_path
      fill_in 'user[login]', with: 'user'
      fill_in 'user[password]', with: 'password'
      click_button 'Login'

      expect(current_path).to eq(my_home_path)
    end

  end

  context 'local_authenticaton is disabled' do
    before { Site.current.update_attributes(:disable_local_auth => true) }
    before(:each) {
      #ApplicationController.any_instance.stub(:referer).and_return('http://example1.com')
      request = double('request')
      allow(request).to receive(:referer).and_return('http://example1.com')
    }

    scenario 'from /login with normal user' do
      visit login_path
      fill_in 'user[login]', with: 'user'
      fill_in 'user[password]', with: 'password'
      click_button 'Login'

      expect(current_path).to eq(new_user_session_path)
    end
    scenario 'from /login with admin' do
      visit login_path
      fill_in 'user[login]', with: 'admin'
      fill_in 'user[password]', with: 'admin'
      click_button 'Login'

      expect(current_path).to eq(my_home_path)
    end
  end
end


