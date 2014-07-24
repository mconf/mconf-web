require 'spec_helper'

feature 'Visitor logs in' do
  before(:each) { FactoryGirl.create(:user, :username => 'user', :password => 'password') }

  scenario 'with valid email and password' do
    sign_in_with 'user', 'password'

    expect(page).to have_title('Mconf')
    expect(page).to have_content('My spaces')
    expect(current_path).to eq(my_home_path)
  end

  scenario 'with invalid email' do
    sign_in_with 'invalid_email', 'password'

    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content 'Invalid email or password'
  end

  feature 'with valid email and password' do
    before(:each) {
      #ApplicationController.any_instance.stub(:referer).and_return('http://example1.com')
      request = double('request')
      allow(request).to receive(:referer).and_return('http://example1.com')
    }
    let(:room) { FactoryGirl.create(:bigbluebutton_room, :param => "test") }

    scenario 'from the frontpage' do
      visit root_path
      fill_in 'user[login]', with: 'user'
      find('#login-box').find('#user_password').set('password')
      click_button 'Login'

      expect(current_path).to eq(my_home_path)
    end

    scenario 'from /login' do
      visit login_path
      fill_in 'user[login]', with: 'user'
      fill_in 'user[password]', with: 'password'
      click_button 'Login'

      expect(current_path).to eq(my_home_path)
    end

    scenario 'from /webconf/:id' do
      user = FactoryGirl.create(:user)
      room = FactoryGirl.create(:bigbluebutton_room, :param => "test", :owner => user)
      visit invite_bigbluebutton_room_path(room)
      fill_in 'user[login]', with: 'user'
      fill_in 'user[password]', with: 'password'
      click_button 'Login'

      expect(current_path).to eq(invite_bigbluebutton_room_path(room))
    end
  end

  def sign_in_with(user_email, password)
    visit new_user_session_path
    fill_in 'user[login]', with: user_email
    fill_in 'user[password]', with: password
    click_button 'Login'
  end
end
