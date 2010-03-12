module ActiveRecord #:nodoc:
  module Agent
    # Agent Authentication Methods
    module Authentication
      # Login and Password authentication support
      module LoginAndPassword
        def self.included(base) #:nodoc:
          base.extend ClassMethods
          base.class_eval do
            # Virtual attribute for the unencrypted password
            attr_accessor :password

            validates_presence_of     :login, :email
            validates_presence_of     :password,                   :if => "needs_password? && password_not_saved?"
            validates_presence_of     :password_confirmation,      :if => "needs_password? && password_not_saved?"
            validates_length_of       :password, :within => 4..40, :if => "needs_password? && password_not_saved?"
            validates_confirmation_of :password,                   :if => "needs_password? && password_not_saved?"
            validates_length_of       :login,    :within => 1..40
            validates_length_of       :email,    :within => 5..100
            validates_uniqueness_of   :login, :email, :case_sensitive => false

            before_save :encrypt_password
            # prevents a user from submitting a crafted form that bypasses activation
            # anything else you want your user to change should be added here.
            attr_accessible :login, :email, :password, :password_confirmation

            include InstanceMethods
          end
        end

        module ClassMethods
          # Authenticates a user by their login name and unencrypted password. 
          # Returns the agent or nil.
          def authenticate_with_login_and_password(login, password)
            u = find_by_login(login)
            u && u.password_authenticated?(password) ? u : nil
          end

          # Encrypts some data with the salt.
          def encrypt(password, salt)
            Digest::SHA1.hexdigest("--#{salt}--#{password}--")
          end
        end

        module InstanceMethods
          # Encrypts the password with the user salt
          def encrypt(password)
            self.class.encrypt(password, salt)
          end

          def password_authenticated?(password)
            crypted_password == encrypt(password)
          end

          protected
            # before filter 
            def encrypt_password
              return if password.blank?
              self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
              self.crypted_password = encrypt(password)
            end

            def password_not_saved?
              crypted_password.blank? || !password.blank?
            end

        end
      end
    end
  end
end
