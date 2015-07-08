# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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

  def current_path_with_query
    uri = URI.parse(current_url)
    "#{uri.path}#{'?' + uri.query if uri.query}"
  end

  def logout_user
    find("a[href='#{logout_path}']").click
  end

  def have_image src
    have_xpath("//img[contains(@src,\"#{src}\")]")
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
    click_button I18n.t("sessions.login_form.login")
  end

  def register_with(attrs)
    name = attrs[:username] || (attrs[:_full_name].downcase.gsub(/\s/, '-') if attrs[:_full_name])
    password_confirmation = attrs[:password_confirmation] || attrs[:password]
    visit register_path
    fill_in "user[email]", with: attrs[:email]
    fill_in "user[_full_name]", with: attrs[:_full_name]
    fill_in "user[username]", with: name
    fill_in "user[password]", with: attrs[:password]
    fill_in "user[password_confirmation]", with: password_confirmation
    click_button I18n.t("registrations.signup_form.register")
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

  # Verifies that an input field has an error in it (for simple_form fields).
  # `field_class` is the class added to the field, such as "user_name" or
  # "space_description".
  def has_field_with_error field_class
    finder = ".#{field_class}.field_with_errors .error"
    page.should have_css(finder)
    page.find(finder).should be_visible
  end

  def have_notification(text)
    have_selector("#notification-flashs", :text => text)
  end

  def have_empty_notification
    page.find("#notification-flashs").text.should eql('')
    page.find("#notification-flashs").all('*').length.should eql(0)
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def email_by_subject(subject)
    ActionMailer::Base.deliveries.each do |mail|
      return mail if mail.subject.match(subject)
    end
    nil
  end

  def should_not_be_500_page
    page.should_not have_title(t('error.e500.title'))
    page.should_not have_content(t('error.e500.title'))
    page.should_not have_content(t('error.e500.description', :url => page.current_path))
    page.status_code.should < 500 && page.status_code.should  >= 200
  end

  def should_be_404_page
    page.should have_title(t('error.e404.title'))
    page.should have_content(t('error.e404.title'))
    page.should have_content(t('error.e404.description', :url => page.current_path))
    page.status_code.should == 404
  end

  def should_be_403_page(title=nil, msg=nil)
    if title.present?
      page.should have_content(title)
    else
      page.should have_content(t('error.e403.title'))
    end
    if msg.present?
      page.should have_content(msg)
    else
      page.should have_content(t('error.e403.description'))
    end
    page.status_code.should == 403
  end

  # Use it as:
  # expect { register_with(attrs) }.to send_email
  def send_email(count=nil)
    if count.present?
      change{ ActionMailer::Base.deliveries.length }.by(1)
    else
      change{ ActionMailer::Base.deliveries.length }
    end
  end
end

shared_examples_for 'it redirects to login page' do
  it { [login_path, new_user_session_path].should include(current_path) }
end
