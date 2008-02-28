require 'digest/sha1'
class User < ActiveRecord::Base
  has_one :profile
  
  has_many :participants
  has_and_belongs_to_many :events
  has_and_belongs_to_many :machines 
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
 attr_accessible :email_confirmed
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :email2, :email3, :password, :password_confirmation, :superuser, :disabled

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  # the user can also authenticate with (email, passwd), (email2, passwd) or (email3, passwd)
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    unless u
      u = find_by_email(login)
      unless u
        u = find_by_email2(login)
        unless u
          u = find_by_email3(login)
        end
      end
    end
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
def forgot_password
     @forgotten_password = true
     self.make_password_reset_code
   end

   def reset_password
     # First update the password_reset_code before setting the 
     # reset_password flag to avoid duplicate email notifications.
     update_attributes(:password_reset_code => nil)
     @reset_password = true
   end

   def recently_reset_password?
     @reset_password
   end

   def recently_forgot_password?
     @forgotten_password
   end

  
   #callback that replace empty strings in email2 and email3 for NULL
   def before_save
     if self.email2==""
       self.email2 = nil
     end
     if self.email3==""
       self.email3 = nil
     end
     
   end

   
  
  protected
  def make_password_reset_code
     self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
   end
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
end
