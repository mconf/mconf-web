class XmppServer < SingularAgent
  acts_as_agent :authentication => [ :login_and_password ],
                :invite => false,
                :login_and_password => { :login => nil, :email => nil }

  class << self
    def authenticate_with_login_and_password(login, password)
      login == current.login &&
        password.present? &&
        current.password_authenticated?(password) ?
        current :
        nil
    end
  end

  def login
    'xmpp_server'
  end
end
