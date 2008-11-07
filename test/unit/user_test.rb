require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate_with_login_and_password('quentin', 'test')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end
def test_forgot_password
  u = users(:quentin)
  u.forgot_password
  assert_not_nil u.reset_password_code
end

def test_reset_password
 u = users(:quentin)
 u.reset_password
 assert_nil u.reset_password_code
end

def test_callbacks
  us = User.new(:login => 'test', :email=>'test@test.es', :password => 'quire', :password_confirmation => 'quire')
  assert_valid us
end

  def test_should_parse_atom
    data = prepare_atom("dos", "desc", "uno@email.com", ["t1", "t2", "t3", "t4", "t5"])
    params = User.atom_parser(data)
    assert params.include?(:user)
    assert_equal "dos", params[:user][:login]
    assert_equal "desc", params[:user][:password]
    assert_equal "uno@email.com", params[:user][:email]
    assert_equal "t1,t2,t3,t4,t5", params[:tags]
  end
  
    def test_should_parse_atom2
    data = prepare_atom("dos", "desc", "uno@email.com", ["t1", "t2", "t3"])
    params = User.atom_parser(data)
    assert params.include?(:user)
    assert_equal "dos", params[:user][:login]
    assert_equal "desc", params[:user][:password]
    assert_equal "uno@email.com", params[:user][:email]
    assert_equal "t1,t2,t3,,", params[:tags]
  end



protected
  def create_user(options = {})
    User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
  
    def prepare_atom(title, password, email, options = {})
    d = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <entry xmlns:gd=\"http://schemas.google.com/g/2005\" 
    xmlns:sir=\"http://sir.dit.upm.es/schema\" 
    xml:lang=\"en-US\" xmlns=\"http://www.w3.org/2005/Atom\">  
    <id>tag:localhost,2005:User/3</id>  
    <published>2008-04-03T17:34:59+02:00</published>  
    <updated>2008-04-03T17:34:59+02:00</updated>  
    <link type=\"text/html\" rel=\"alternate\" href=\"http://localhost:3000/users/1\"/>  
    <link type=\"application/atom+xml\" rel=\"self\" href=\"http://localhost:3000/spaces/1/users/1.atom\"/>  
    <title>#{title}</title>  
    <sir:password>#{password}</sir:password>  
    <gd:email address=\"#{email}\" primary=\"true\" label=\"email1\"/>
    <category term=\"#{options[0]}\"/> 
    <category term=\"#{options[1]}\"/>  
    <category term=\"#{options[2]}\"/> 
    <category term=\"#{options[3]}\"/> 
    <category term=\"#{options[4]}\"/> 
    </entry>"
  end

  
  
end
