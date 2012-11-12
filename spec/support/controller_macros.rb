module ControllerMacros

  # Creates a new admin user and logs him in
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user ||= FactoryGirl.create(:superuser)
      sign_in @user
      @user
    end
  end

  # Creates a new normal user and logs him in
  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user ||= FactoryGirl.create(:user)
      sign_in @user
      @user
    end
  end

end
