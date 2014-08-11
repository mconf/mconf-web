include Warden::Test::Helpers
Warden.test_mode!

# Shorthand for I18n.t
def t *args
  I18n.t(*args)
end

def show_page
  save_page Rails.root.join( 'public', 'capybara.html' )
  %x(launchy http://localhost:3000/capybara.html)
end

def has_success_message message=nil
  # TODO
  # we sometimes show success on 'notice' and sometimes on 'success'
  success_css = '#notification-flashs > div[name=notice],div[name=success]'
  page.should have_css(success_css)
  page.find(success_css).should have_content(message)
end

def has_failure_message message=nil
  page.should have_css('#notification-flashs > div[name=alert]')
  page.find('#notification-flashs > div[name=alert]').should have_content(message)
end