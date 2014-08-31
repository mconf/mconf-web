include Warden::Test::Helpers
Warden.test_mode!

# General purpose helpers
module FeatureHelpers

  def enable_shib
    Site.current.update_attributes(
      :shib_enabled => true,
      :shib_name_field => "Shib-inetOrgPerson-cn",
      :shib_email_field => "Shib-inetOrgPerson-mail",
      :shib_principal_name_field => "Shib-eduPerson-eduPersonPrincipalName"
    )
  end

  def setup_shib name, email, principal
    driver_name = "rack_test_#{rand}".to_sym
    Capybara.register_driver driver_name do |app|
      Capybara::RackTest::Driver.new(app, :headers => {
        "Shib-inetOrgPerson-cn" => name,
        "Shib-inetOrgPerson-mail" => email,
        "Shib-eduPerson-eduPersonPrincipalName" => principal
      })
    end
    Capybara.current_driver = driver_name
  end

  def logout_user
    find("a[href='#{logout_path}']").click
  end

  # Shorthand for I18n.t
  def t *args
    I18n.t(*args)
  end

  def show_page
    save_page Rails.root.join( 'public', 'capybara.html' )
    %x(launchy http://localhost:3000/capybara.html)
  end

  def sign_in_with(user_email, password, visit_page=true)
    visit(new_user_session_path) if visit_page
    fill_in 'user[login]', with: user_email
    fill_in 'user[password]', with: password
    click_button 'Login'
  end

  def has_success_message message=nil
    # TODO
    # we sometimes show success on 'notice' and sometimes on 'success'
    success_css = '#notification-flashs > div[name=notice],div[name=success]'
    page.should have_css(success_css)
    page.find(success_css).should have_content(message)
  end

  def has_failure_message message=nil
    # TODO
    # we sometimes show success on 'alert' and sometimes on 'error'
    error_css = '#notification-flashs > div[name=alert],div[name=error]'
    page.should have_css(error_css)
    page.find(error_css).should have_content(message)
  end

  def have_notification(text)
    have_selector("#notification-flashs", :text => text)
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

end
