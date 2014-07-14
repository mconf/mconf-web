include Warden::Test::Helpers
Warden.test_mode!

def show_page
  save_page Rails.root.join( 'public', 'capybara.html' )
  %x(launchy http://localhost:3000/capybara.html)
end
