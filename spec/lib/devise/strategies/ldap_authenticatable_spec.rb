# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Devise::Strategies::LdapAuthenticatable do

  let(:target) { Devise::Strategies::LdapAuthenticatable.new(nil) }

  describe "#valid?" do
    context "if ldap_enabled?" do
      before { Site.current.update_attributes(:ldap_enabled => true) }
      it { target.valid?.should be_true }
    end

    context "if not ldap_enabled?" do
      before { Site.current.update_attributes(:ldap_enabled => false) }
      it { target.valid?.should be_false }
    end
  end

  describe "#authenticate!" do

    context "if LDAP is enabled and there's user information in the params" do
      let(:params) { { :user => { :login => "user-login", :password => "user-password" } } }
      let(:ldap_site_params) {
        { :ldap_user => "ldap-user", :ldap_user_password => "ldap-password",
          :ldap_user_treebase => "ldap-treebase" }
      }
      before {
        Site.current.update_attributes(:ldap_enabled => true)
        Site.current.update_attributes(ldap_site_params)
        target.stub(:params).and_return(params)

        # a fake LDAP object that will receive and do most of the actions
        @ldap_mock = double(Net::LDAP)
        Net::LDAP.should_receive(:new).and_return(@ldap_mock)
        @ldap_mock.should_receive(:auth).with("ldap-user", "ldap-password")
      }

      context "if the binding of the admin user is successful" do
        before {
          @ldap_mock.should_receive(:bind).and_return(true)
        }

        context "if the binding of the target user is successful" do
          before {
            # a fake filter
            filter = double(:filter)
            target.should_receive(:ldap_filter).and_return(filter)

            # binding the target user to the server
            @ldap_mock.should_receive(:bind_as)
              .with({ :base => "ldap-treebase", :filter => filter, :password => "user-password" })
              .and_return(["first ldap user", "second ldap user"])

            # validates the ldap user
            target.should_receive(:validate_ldap_user).with("first ldap user", Site.current)
		      .and_return(true)

            # a fake user to be 'created and returned'
            @user = double(:user)
            target.should_receive(:find_or_create_user).with("first ldap user", Site.current)
              .and_return(@user)
          }

          it("calls and returns #success!(user)") {
            target.should_receive(:success!).with(@user).and_return("return of success!")
            target.authenticate!.should eq("return of success!")
          }
        end

        context "if the binding of the target user fails" do
          before {
            @ldap_mock.should_receive(:bind_as).and_return(false) # bind failed
            @ldap_mock.stub_chain(:get_operation_result, :code).and_return("ldap error code")
            @ldap_mock.stub_chain(:get_operation_result, :message).and_return("ldap error message")
          }
          it("calls and returns #fail(:invalid)") {
            target.should_receive(:fail).with(:invalid).and_return("return of fail!")
            target.authenticate!.should eq("return of fail!")
          }
        end
      end

      context "if the binding of the admin user fails" do
        before {
          @ldap_mock.should_receive(:bind).and_return(false) # binding failed
          @ldap_mock.stub_chain(:get_operation_result, :code).and_return("ldap error code")
          @ldap_mock.stub_chain(:get_operation_result, :message).and_return("ldap error message")
        }
        it("calls and returns #fail!(message)") {
          msg = I18n.t('devise.strategies.ldap_authenticatable.invalid_bind')
          target.should_receive(:fail!).with(msg).and_return("return of fail!")
          target.authenticate!.should eq("return of fail!")
        }
      end
    end

    context "if LDAP is not enabled" do
      before {
        Site.current.update_attributes(:ldap_enabled => false)
      }
      it("calls and returns #fail!(message)") {
        msg = I18n.t('devise.strategies.ldap_authenticatable.ldap_not_enabled')
        target.should_receive(:fail).with(msg).and_return("return of fail!")
        target.authenticate!.should eq("return of fail!")
      }
    end

    context "if LDAP is enabled but there's no user information in the params" do
      before {
        Site.current.update_attributes(:ldap_enabled => true)
        target.stub(:params).and_return({ :anything => 1 })
      }
      it("calls and returns #fail!(:invalid)") {
        target.should_receive(:fail).with(:invalid).and_return("return of fail!")
        target.authenticate!.should eq("return of fail!")
      }
    end
  end

  describe "#login_from_params" do
    context "returns the login set in the params hash" do
      before { target.should_receive(:params).and_return({ :user => { :login => "any-login" } }) }
      it { target.login_from_params.should eq("any-login") }
    end
  end

  describe "#password_from_params" do
    context "returns the password set in the params hash" do
      before { target.should_receive(:params).and_return({ :user => { :password => "any-password" } }) }
      it { target.password_from_params.should eq("any-password") }
    end
  end

  describe "#ldap_configs" do
    it("returns the current site") { target.ldap_configs.should eq(Site.current) }
  end

  describe "#ldap_filter" do
 
    let(:params) { { :user => { :login => "user-login", :password => "user-password" } } }
    context "returns an instance of Net::LDAP::filter configured the correct parameters" do
      before {
          @ldap_filter = double(Net::LDAP::Filter.eq("uid", "userlogin"))
      }
      it { target.ldap_filter(@ldap_filter).should_return(@ldap_filter) }
    end
  end

  describe "#ldap_enabled?" do
    it "returns whether LDAP is enabled in the current site"
  end

  describe "#ldap_connection" do
    context "if using port 636" do
      it "returns an instance of Net::LDAP with the correct host and port and set to use simple_tls"
    end
    context "if the port is not 636" do
      it "returns an instance of Net::LDAP with the correct host and port, without simple_tls"
    end
  end

  describe "#find_or_create_user" do
    context "if the username field set in the configurations exists in the user information" do
      it "uses it"
    end
    context "if the username field set in the configurations does not exist in the user information" do
      it "uses a default username"
    end
    context "if the name field set in the configurations exists in the user information" do
      it "uses it"
    end
    context "if the name field set in the configurations does not exist in the user information" do
      it "uses a default name"
    end
    context "if the email field set in the configurations exists in the user information" do
      it "uses it"
    end
    context "if the email field set in the configurations does not exist in the user information" do
      it "uses a default email"
    end
    it "calls #find_or_create_token with the correct parameters to get the token"
    it "calls #create_account with the correct parameters to get the user"
    it "sets the user in the token and saves it"
    it "returns the user created"
  end

  describe "#find_or_create_token" do
    it "returns the token found if one already exists"
    it "creates a new token for the identifier passed if it doesn't exist yet"

    # These tests are here to prevent errors when creating the token, because the id passed is
    # usually not a standard ruby string, but a Net::BER::BerIdentifiedString created by net-ldap.
    # More at: https://github.com/hallelujah/valid_email/issues/22
    it "converts the id passed to a string"
  end

  describe "#create_account" do
    it "returns the user found if one already exists"
    context "if the target user doesn't exist yet, creates a new user" do
      it "with a random password"
      it "with the email, username and full_name passed"
      it "skips the confirmation, marking the user as already confirmed"
    end

    # These tests are here to prevent errors when creating the token, because the id passed is
    # usually not a standard ruby string, but a Net::BER::BerIdentifiedString created by net-ldap.
    # More at: https://github.com/hallelujah/valid_email/issues/22
    it "converts the id passed to a string"
    it "converts the username passed to a string"
    it "converts the full_name passed to a string"
  end

end
