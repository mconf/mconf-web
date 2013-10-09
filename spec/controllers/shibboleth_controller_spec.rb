# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ShibbolethController do

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

  describe "#login" do

    context "before filters" do
      let(:run_route) { get :login }
      it_should_behave_like "has the before_filter :check_shib_enabled"
      it_should_behave_like "has the before_filter :check_current_user"
    end

    context "renders an error page if there's not enough information on the session" do
      before { Site.current.update_attributes(:shib_enabled => true) }
      before(:each) { get :login }
      it { should render_template('error') }
      it { should render_with_layout('no_sidebar') }
      it { should set_the_flash.to(I18n.t('shibboleth.login.not_enough_data')) }
    end

    context "if the user's information is ok" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        request.env["Shib-inetOrgPerson-cn"] = user.full_name
        request.env["Shib-inetOrgPerson-mail"] = user.email
        Site.current.update_attributes(:shib_enabled => true)
      }

      context "logs the user in if he already has a token" do
        before { ShibToken.create!(:identifier => user.email, :user => user) }
        before(:each) { get :login }
        it { subject.current_user.should eq(user) }
        it { should redirect_to(my_home_path) }
      end

      context "renders the association page if the user doesn't have a token yet" do
        before(:each) { get :login }
        it { should render_template('login') }
        it { should render_with_layout('no_sidebar') }
      end

    end
  end

  describe "#create_association" do

    context "before filters" do
      let(:run_route) { post :create_association }
      it_should_behave_like "has the before_filter :check_shib_enabled"
      it_should_behave_like "has the before_filter :check_current_user"
    end

    context "if params has no known option, redirects to /secure with a warning" do
      let(:user) { FactoryGirl.create(:user) }
      before {
        request.env["Shib-inetOrgPerson-cn"] = user.full_name
        request.env["Shib-inetOrgPerson-mail"] = user.email
        Site.current.update_attributes(:shib_enabled => true)
      }
      before(:each) { post :create_association }
      it { should redirect_to(shibboleth_path) }
      it { should set_the_flash.to(I18n.t('shibboleth.create_association.invalid_parameters')) }
    end

    context "if params[:new_account] is set" do
      let(:attrs) { FactoryGirl.attributes_for(:user) }
      before {
        request.env["Shib-inetOrgPerson-cn"] = attrs[:_full_name]
        request.env["Shib-inetOrgPerson-mail"] = attrs[:email]
        Site.current.update_attributes(:shib_enabled => true)
        # save it to the session, as #login would do
        shib = Mconf::Shibboleth.new(session)
        shib.save_to_session(request.env)
      }

      context "redirects to /secure if the user already has a valid token" do
        let(:user) { FactoryGirl.create(:user) }
        before { ShibToken.create!(:identifier => user.email, :user => user) }
        before(:each) { post :create_association, :new_account => true }
        it { should redirect_to(shibboleth_path) }
      end

      context "if there's no valid token yet" do

        context "creates a new token with the correct information and goes back to /secure" do
          before(:each) {
            expect {
              post :create_association, :new_account => true
            }.to change{ ShibToken.count }.by(1)
          }
          subject { ShibToken.last }
          it { subject.identifier.should eq(attrs[:email]) }
          it { subject.user.should_not be_nil } # just in case the find_by_email below fails
          it { subject.user.should eq(User.find_by_email(attrs[:email])) }
          it {
            expected = {}
            expected["Shib-inetOrgPerson-cn"] = attrs[:_full_name]
            expected["Shib-inetOrgPerson-mail"] = attrs[:email]
            subject.data.should eq(expected.to_yaml) # it's a Hash in the db, so compare using to_yaml
          }
          it { controller.should redirect_to(shibboleth_path) }
          it { controller.should set_the_flash.to(I18n.t('shibboleth.create_association.account_created', :url => new_user_password_path)) }
        end

        context "if fails to create the new user, goes to /secure with an error message" do
          before {
            @user = FactoryGirl.build(:user)
            @user.errors.add(:name, "can't be blank") # any fake error
            Mconf::Shibboleth.any_instance.should_receive(:create_user).and_return(@user)
          }
          before(:each) {
            expect {
              post :create_association, :new_account => true
            }.not_to change{ ShibToken.count }
          }
          it { controller.should redirect_to(shibboleth_path) }
          it { controller.should set_the_flash.to(I18n.t('shibboleth.create_association.error_saving_user', :errors => @user.errors.full_messages.join(', '))) }
        end

        context "if there's already a user with the target email, goes to /secure with an error message" do
          before { FactoryGirl.create(:user, :email => attrs[:email]) }
          before(:each) {
            expect {
              post :create_association, :new_account => true
            }.not_to change{ ShibToken.count }
          }
          it { controller.should redirect_to(shibboleth_path) }
          it { controller.should set_the_flash.to(I18n.t('shibboleth.create_association.existent_account', :email => attrs[:email])) }
        end
      end
    end

  end

  describe "#info" do
    before { Site.current.update_attributes(:shib_enabled => true) }

    context "assigns @data with the data in the session" do
      let(:expected) { { :one => "anything" } }
      before { controller.session[:shib_data] = expected }
      before(:each) { get :info }
      it { should assign_to(:data).with(expected) }
    end

    context "renders with no layout" do
      before(:each) { get :info }
      it { should_not render_with_layout() }
    end
  end

  # set some basic things so that the login via shibboleth will work
  def basic_shibboleth_setup(user)
  end

end
