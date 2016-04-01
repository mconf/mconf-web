# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ShibbolethController do

  # set the default values usually used to get data from Shibboleth
  before {
    Site.current.update_attributes(:shib_name_field => "Shib-inetOrgPerson-cn",
                                   :shib_email_field => "Shib-inetOrgPerson-mail",
                                   :shib_principal_name_field => "Shib-eduPerson-eduPersonPrincipalName")
  }

  shared_examples_for "has the before_filter :check_shib_enabled" do
    context "redirects to /login if shibboleth is disabled" do
      before { Site.current.update_attributes(:shib_enabled => false) }
      before(:each) { run_route }
      it { should redirect_to(login_path) }
    end
  end

  shared_examples_for "has the before_filter :check_current_user" do
    context "redirects to the user's home if there's already a user logged" do
      let(:user) { FactoryGirl.create(:user) }
      before { Site.current.update_attributes(:shib_enabled => true) }
      before(:each) {
        login_as(user)
        run_route
      }
      it { should redirect_to(my_home_path) }
    end
  end

  shared_examples_for "a caller of #associate_with_new_account" do
    let(:attrs) { FactoryGirl.attributes_for(:user) }

    context "redirects to /secure if the user already has a valid token" do
      let(:user) { FactoryGirl.create(:user) }
      before { ShibToken.create!(:identifier => user.email, :user => user) }
      before(:each) { run_route }
      it { should redirect_to(shibboleth_path) }
      context "creates a RecentActivity" do
        subject { RecentActivity.where(key: 'shibboleth.user.created').last }
        it("should exist") { subject.should_not be_nil }
        it("should point to the right trackable") { subject.trackable.should eq(User.last) }
        it("should be unnotified") { subject.notified.should be(false) }
       # see #1737
        it("should be owned by a ShibToken") { subject.owner.class.should be(ShibToken) }
        it("should be owned by the correct ShibToken") { subject.owner_id.should eql(ShibToken.last.id) } # calls the last ShibToken because now the RecentActivity is created after the token is save in the database
      end
    end

    context "if there's no valid token yet" do

      context "creates a new token with the correct information and goes back to /secure" do
        before(:each) {
          expect { run_route }.to change{ ShibToken.count }.by(1)
        }
        subject { ShibToken.last }
        it { subject.identifier.should eq(attrs[:email]) }
        it { subject.user.should_not be_nil } # just in case the find_by_email below fails
        it { subject.user.should eq(User.find_by_email(attrs[:email])) }
        it {
          expected = {}
          expected["Shib-inetOrgPerson-cn"] = attrs[:_full_name]
          expected["Shib-inetOrgPerson-mail"] = attrs[:email]
          expected["Shib-eduPerson-eduPersonPrincipalName"] = attrs[:email]
          subject.data.should eq(expected)
        }
        it { controller.should redirect_to(shibboleth_path) }
        it { controller.should set_flash.to(I18n.t('shibboleth.create_association.account_created', :url => new_user_password_path)) }
        it { RecentActivity.where(owner: subject, trackable: subject.user, key: 'shibboleth.user.created').should_not be_nil }
      end

      context "if fails to create the new user, goes to /secure with an error message" do
        before {
          @user = FactoryGirl.build(:user)
          @user.errors.add(:name, "can't be blank") # any fake error
          Mconf::Shibboleth.any_instance.should_receive(:create_user).and_return(@user)
        }
        before(:each) {
          expect { run_route }.not_to change{ ShibToken.count }
        }
        it { controller.should redirect_to(shibboleth_path) }
        it { controller.should set_flash.to(I18n.t('shibboleth.create_association.error_saving_user', :errors => @user.errors.full_messages.join(', '))) }
        it { RecentActivity.where(trackable: @user, key: 'shibboleth.user.created').should be_empty }
      end

      context "if there's already a user with the target email, goes to /secure with an error message" do
        before { FactoryGirl.create(:user, :email => attrs[:email]) }
        before(:each) {
          expect { run_route }.not_to change{ ShibToken.count + RecentActivity.count }
        }
        it { controller.should redirect_to(shibboleth_path) }
        it { controller.should set_flash.to(I18n.t('shibboleth.create_association.existent_account', :email => attrs[:email])) }
      end
    end
  end

  describe "#login" do

    context "before filters" do
      let(:run_route) { get :login }
      it_should_behave_like "has the before_filter :check_shib_enabled"
      it_should_behave_like "has the before_filter :check_current_user"
      skip "has the before_filter :load_shib_session"
    end

    # to make sure we're not forgetting a call to #test_data (happened before)
    it "doesn't call #test_data" do
      Site.current.update_attributes(:shib_enabled => true)
      controller.should_not_receive(:test_data)
      get :login
      request.env.each { |key, value| key.should_not match(/shib-/i) }
    end

    context "renders an error page if there's not enough information on the session" do
      before {
        Site.current.update_attributes(:shib_name_field => 'name', :shib_email_field => 'email', :shib_principal_name_field => 'principal_name')
        Site.current.update_attributes(:shib_enabled => true)
        request.env['Shib-Any'] = 'any'
      }
      before(:each) { get :login }
      it { should render_template('attribute_error') }
      it { should render_with_layout('no_sidebar') }
      it { should assign_to(:attrs_required).with(['email', 'name', 'principal_name']) }
      it { should assign_to(:attrs_informed).with({ 'Shib-Any' => 'any' }) }
    end

    context "if the user's information is ok" do
      let(:user) { FactoryGirl.create(:user) }
      before { setup_shib(user.full_name, user.email, user.email) }

      context "if the user already has a token" do
        before { ShibToken.create!(:identifier => user.email, :user => user) }

        context "if the site does not require admin approval, logs the user in" do
          before(:each) {
            request.flash[:success] = 'message set previously by #create_association'
            should set_flash.to('message set previously by #create_association')
            get :login
          }
          it { subject.current_user.should eq(user) }
          it { should redirect_to(my_home_path) }
          skip("persists the flash messages") {
            # TODO: The flash is being set and flash.keep is called, but this test doesn't work.
            #  Testing in the application the flash is persisted, as it should.
            should set_flash.to('message set previously by #create_association')
          }
        end

        context "if the site requires admin approval, shows the pending approval page" do
          before(:each) {
            Site.current.update_attributes(require_registration_approval: true)
            user.update_attributes(approved: false)
            request.flash[:success] = 'message'
            get :login
          }
          it { subject.current_user.should be_nil }
          it { should redirect_to(my_approval_pending_path) }
          it { should_not set_flash }
        end
      end

      context "if the site is set to update user information" do
        before { Site.current.update_attributes(shib_update_users: true) }

        context "updates the user data if the account was created by shib" do
          let(:new_name) { 'New Name' }
          let(:new_email) { 'new-personal@email.com' }
          let(:attrs) { FactoryGirl.attributes_for(:user) }
          before(:each) {
            setup_shib(attrs[:_full_name], attrs[:email], attrs[:email])
            save_shib_to_session

            # new shib user with federation data
            expect {
              post :create_association, :new_account => true
            }.to change{ ShibToken.count }.by(1)

            sign_out ShibToken.last.user

            @old_name = ShibToken.last.user.name
            @old_email = ShibToken.last.user.email
            @old_permalink = ShibToken.last.user.permalink

            # login with different federation data
            setup_shib(new_name, new_email, attrs[:email])
            get :login
          }

          it { ShibToken.last.user.name.should eq(new_name) }
          it { ShibToken.last.user.email.should eq(new_email) }
          it { ShibToken.last.user.confirmed?.should be(true) }
          it { @old_email.should_not eq(new_email) }
          it { @old_name.should_not eq(new_name) }
          it { ShibToken.last.user.permalink.should eq(@old_permalink) }
        end

        context "doesn't update the user data if the account was not created by shib" do
          let(:new_name) { 'New Name' }
          let(:new_email) { 'new-personal@email.com' }
          let(:attrs) { FactoryGirl.attributes_for(:user) }
          before(:each) {
            setup_shib(attrs[:_full_name], attrs[:email], attrs[:email])
            save_shib_to_session

            # new shib user with federation data
            expect {
              post :create_association, :new_account => true
            }.to change{ ShibToken.count }.by(1)

            sign_out ShibToken.last.user

            @old_name = ShibToken.last.user.name
            @old_email = ShibToken.last.user.email
            @old_permalink = ShibToken.last.user.permalink

            ShibToken.last.update_attributes(new_account: false)

            # login with different federation data
            setup_shib(new_name, new_email, attrs[:email])
            get :login
          }

          it { ShibToken.last.user.name.should_not eq(new_name) }
          it { ShibToken.last.user.email.should_not eq(new_email) }
          it { ShibToken.last.user.name.should eq(@old_name) }
          it { ShibToken.last.user.email.should eq(@old_email) }
          it { ShibToken.last.user.permalink.should eq(@old_permalink) }
        end
      end

      context "if the site is not set to update user information" do
        before { Site.current.update_attributes(shib_update_users: false) }

        context "doesn't update the user data even if the account was created by shib" do
          let(:new_name) { 'New Name' }
          let(:new_email) { 'new-personal@email.com' }
          let(:attrs) { FactoryGirl.attributes_for(:user) }
          before(:each) {
            setup_shib(attrs[:_full_name], attrs[:email], attrs[:email])
            save_shib_to_session

            # new shib user with federation data
            expect {
              post :create_association, :new_account => true
            }.to change{ ShibToken.count }.by(1)

            sign_out ShibToken.last.user

            @old_name = ShibToken.last.user.name
            @old_email = ShibToken.last.user.email
            @old_permalink = ShibToken.last.user.permalink

            # login with different federation data
            setup_shib(new_name, new_email, attrs[:email])
            get :login
          }

          it { ShibToken.last.user.name.should_not eq(new_name) }
          it { ShibToken.last.user.email.should_not eq(new_email) }
          it { ShibToken.last.user.name.should eq(@old_name) }
          it { ShibToken.last.user.email.should eq(@old_email) }
          it { ShibToken.last.user.permalink.should eq(@old_permalink) }
        end
      end

      context "renders the association page if the user doesn't have a token yet" do
        before(:each) { get :login }
        it { should render_template('associate') }
        it { should render_with_layout('no_sidebar') }
      end

      context "if the flag shib_always_new_account is set" do
        let(:attrs) { FactoryGirl.attributes_for(:user) }
        before {
          Site.current.update_attributes(:shib_always_new_account => true)
          setup_shib(attrs[:_full_name], attrs[:email], attrs[:email])
        }

        context "skips the association page" do
          before(:each) { get :login }
          it { should set_flash.to(I18n.t('shibboleth.create_association.account_created', :url => new_user_password_path)) }
          it { should redirect_to(shibboleth_path)}
        end

        context "calls #associate_with_new_account" do
          let(:run_route) { get :login }
          it_should_behave_like "a caller of #associate_with_new_account"
        end
      end

      context "user has a token and his local account is disabled" do
        before {
          setup_shib(user.full_name, user.email, user.email)
          ShibToken.create!(:identifier => user.email, :user => user)
          user.disable
        }
        before(:each) { get :login }
        it { should set_flash.to(I18n.t('shibboleth.login.local_account_disabled'))}
        it { should redirect_to(root_path) }
      end

      context "updates the data in the token with the data in the session" do
        let(:old_data) { { "Shib-cn": "My Name", "Shib-id": 12345, "AnotherParam": "no value" } }
        let(:new_data) {
          { "Shib-inetOrgPerson-cn" => user.full_name,
            "Shib-inetOrgPerson-mail" => user.email,
            "Shib-eduPerson-eduPersonPrincipalName" => user.email }
        }
        let!(:token) { ShibToken.create!(identifier: user.email, user: user, data: old_data) }
        before {
          setup_shib(user.full_name, user.email, user.email)
          get :login
        }
        it { token.reload.data.should eql(new_data) }
      end
    end
  end

  describe "#create_association" do

    context "before filters" do
      let(:run_route) { post :create_association }
      it_should_behave_like "has the before_filter :check_shib_enabled"
      it_should_behave_like "has the before_filter :check_current_user"
      skip "has the before_filter :load_shib_session"

      context "has the before filter: ckeck_shib_always_new_account" do

        context "when the flag shib_always_new_account is on" do
          before {
            Site.current.update_attributes(:shib_enabled => true,
                                           :shib_always_new_account => true)
          }
          it { expect { post :create_association }.to raise_error(ActionController::RoutingError) }
        end

        context "when flag shib_always_new_account is off" do
          before {
            Site.current.update_attributes(:shib_enabled => true,
                                           :shib_always_new_account => false)
          }
          context "should be able to call create_association" do
            before(:each) { post :create_association }
            it { expect { post :create_association }.not_to raise_error }
            it("calls the action in the controller") {
              controller.stub(:render) # prevent ActionView::MissingTemplate
              controller.should_receive(:create_association)
              post :create_association
            }
          end
        end
      end
    end

    context "if params has no known option, redirects to /secure with a warning" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        setup_shib(user.full_name, user.email, user.email)
        save_shib_to_session
      }
      before(:each) { post :create_association }
      it { should redirect_to(shibboleth_path) }
      it { should set_flash.to(I18n.t('shibboleth.create_association.invalid_parameters')) }
    end

    context "if params[:new_account] is set" do
      context "calls #associate_with_new_account" do
        let(:run_route) { post :create_association, :new_account => true }
        before {
          setup_shib(attrs[:_full_name], attrs[:email], attrs[:email])
          save_shib_to_session
        }
        it_should_behave_like "a caller of #associate_with_new_account"
      end
    end

    context "if params[:existent_account] is set" do
      let(:attrs) { FactoryGirl.attributes_for(:user) }
      before {
        setup_shib(attrs[:_full_name], attrs[:email], attrs[:email])
        save_shib_to_session
      }

      context "if there's no user info in the params, goes back to /secure with an error" do
        before(:each) { post :create_association, :existent_account => true }
        it { should redirect_to(shibboleth_path) }
        it { should set_flash.to(I18n.t('shibboleth.create_association.invalid_credentials')) }
      end

      context "if the user info in the params is wrong, goes back to /secure with an error" do
        before(:each) { post :create_association, :existent_account => true, :user => { :so_wrong => 2  } }
        it { should redirect_to(shibboleth_path) }
        it { should set_flash.to(I18n.t('shibboleth.create_association.invalid_credentials')) }
      end

      context "if the target user is not found goes back to /secure with an error" do
        before(:each) { post :create_association, :existent_account => true, :user => { :login => 'any' } }
        it { User.find_first_by_auth_conditions({ :login => 'any' }).should be_nil}
        it { should redirect_to(shibboleth_path) }
        it { should set_flash.to(I18n.t('shibboleth.create_association.invalid_credentials')) }
      end

      context "if found the user but the password is wrong goes back to /secure with an error" do
        let(:user) { FactoryGirl.create(:user) }
        before(:each) { post :create_association, :existent_account => true, :user => { :login => user.username } }
        it("finds the user") {
          User.find_first_by_auth_conditions({ :login => user.username }).should_not be_nil
        }
        it { should redirect_to(shibboleth_path) }
        it { should set_flash.to(I18n.t('shibboleth.create_association.invalid_credentials')) }
      end

      context "if the user is disabled goes back to /secure with an error" do
        let(:user) { FactoryGirl.create(:user, :disabled => true, :password => '12345') }
        before(:each) { post :create_association, :existent_account => true, :user => { :login => user.username, :password => '12345' } }
        it("does not find the disabled user") {
          User.find_first_by_auth_conditions({ :login => user.username }).should be_nil
        }
        it { should redirect_to(shibboleth_path) }
        it { should set_flash.to(I18n.t('shibboleth.create_association.invalid_credentials')) }
      end

      context "if the user is found, is authenticated and is not disabled" do
        let(:user) { FactoryGirl.create(:user, :password => '12345') }
        before {
          # the user that is trying to login has to be the same user that has variables
          # on the session, so we do this setup again
          setup_shib(user.full_name, user.email, user.email)
          save_shib_to_session
        }

        context "goes back to /secure with a success message" do
          before(:each) { post :create_association, :existent_account => true, :user => { :login => user.username, :password => '12345' } }
          it("finds the user") {
            User.find_first_by_auth_conditions({ :login => user.username }).should_not be_nil
          }
          it("uses the correct password") {
            User.find_first_by_auth_conditions({ :login => user.username }).valid_password?('12345').should be_truthy
          }
          it { should redirect_to(shibboleth_path) }
          it { should set_flash.to(I18n.t("shibboleth.create_association.account_associated", :email => user.email)) }
        end

        context "creates a ShibToken and associates it with the user" do
          before(:each) {
            user.update_attributes(:confirmed_at => nil)
            expect {
              post :create_association, :existent_account => true, :user => { :login => user.username, :password => '12345' }
            }.to change{ ShibToken.count }.by(1) && change{ User.where("users.confirmed_at IS NOT NULL").count }.by(1)
          }
          subject { ShibToken.last }
          it("sets the user in the token") { subject.user.should eq(user) }
          it("sets the data in the token") { subject.data.should eq(@shib.get_data()) }
          it("confirms the account if it's unconfirmed") { subject.user.confirmed?.should be(true) }
        end

        context "creates a ShibToken and deletes the old one if the user was associated with another federation account" do
          let!(:old_shib) { ShibToken.create!(:identifier => "ninjaedit#{user.email}", user: user) }
          before(:each) {
            user.update_attributes(:confirmed_at => nil)
            expect {
              post :create_association, :existent_account => true, :user => { :login => user.username, :password => '12345' }
            }.to change{ ShibToken.count }.by(0) && change{ User.where("users.confirmed_at IS NOT NULL").count }.by(1)
          }
          subject { ShibToken.last }
          it("created a different token") { subject.should_not eq(old_shib) }
          it("sets the user in the token") { subject.user.should eq(user) }
          it("sets the data in the token") { subject.data.should eq(@shib.get_data()) }
          it("confirms the account if it's unconfirmed") { subject.user.confirmed?.should be(true) }
        end

        context "uses the user's ShibToken if it already exists" do
          before { ShibToken.create!(:identifier => user.email, :user_id => user.id) }
          before(:each) {
            user.update_attributes(:confirmed_at => nil)
            expect {
              post :create_association, :existent_account => true, :user => { :login => user.username, :password => '12345' }
            }.to change{ ShibToken.count }.by(0) && change{ User.where("users.confirmed_at IS NOT NULL").count }.by(1)
          }
          subject { ShibToken.last }
          it("sets the user in the token") { subject.user.should eq(user) }
          it("sets the data in the token") { subject.data.should eq(@shib.get_data()) }
          it("confirms the account if it's unconfirmed") { subject.user.confirmed?.should be(true) }
        end

      end
    end

  end

  describe "#info" do
    let(:user) { FactoryGirl.create(:user) }
    let(:shib_token) { FactoryGirl.create(:shib_token, user: user) }
    before {
      Site.current.update_attributes(:shib_enabled => true)
    }

    context "assigns @data" do
      context "with the data in the user's token" do
        let(:expected) { { :one => "anything" } }
        before {
          shib_token.update_attributes(data: expected)
          sign_in(user)
        }
        before(:each) { get :info }
        it { should assign_to(:data).with(expected) }
      end

      context "with nil if there's no user signed in" do
        before(:each) { get :info }
        it { assigns(:data).should be_nil }
      end

      context "with nil if the user has no shib_token" do
        before(:each) { get :info }
        before {
          shib_token.destroy
          sign_in(user)
        }
        it { assigns(:data).should be_nil }
      end
    end

    context "renders with no layout" do
      before(:each) { get :info }
      it { should_not render_with_layout() }
    end
  end

  private

  # Sets up the login via shibboleth, including user information in the enviroment.
  # Doesn't automatically save this information in the session because this is something
  # ShibbolethController should do and it should be tested for it.
  def setup_shib(name, email, principal_name=nil)
    request.env["Shib-inetOrgPerson-cn"] = name
    request.env["Shib-inetOrgPerson-mail"] = email
    request.env["Shib-eduPerson-eduPersonPrincipalName"] = principal_name || email
    Site.current.update_attributes(:shib_enabled => true)
  end

  # Save it to the session, as #login would do
  def save_shib_to_session
    @shib = Mconf::Shibboleth.new(session)
    @shib.load_data(request.env)
  end

end
