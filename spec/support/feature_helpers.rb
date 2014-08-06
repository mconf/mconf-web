include Warden::Test::Helpers
Warden.test_mode!

def show_page
  save_page Rails.root.join( 'public', 'capybara.html' )
  %x(launchy http://localhost:3000/capybara.html)
end

def has_success_message message=nil
  page.should have_css('#notification-flashs > div[name=notice]')
  page.find('#notification-flashs > div[name=notice]').should have_content(message)
end

def has_failure_message message=nil
  page.should have_css('#notification-flashs > div[name=alert]')
  page.find('#notification-flashs > div[name=alert]').should have_content(message)
end