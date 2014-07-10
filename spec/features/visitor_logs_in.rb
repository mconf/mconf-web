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

  def sign_in_with(user_email, password)
    visit new_user_session_path
    fill_in 'user[login]', with: user_email
    fill_in 'user[password]', with: password
    click_button 'Login'
  end
end