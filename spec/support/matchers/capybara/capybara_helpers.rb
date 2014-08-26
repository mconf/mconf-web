# General purpose capybara helpers
module CapybaraHelpers

  def sign_in_with(user_email, password, visit_page=true)
    visit(new_user_session_path) if visit_page
    fill_in 'user[login]', with: user_email
    fill_in 'user[password]', with: password
    click_button 'Login'
  end

end
