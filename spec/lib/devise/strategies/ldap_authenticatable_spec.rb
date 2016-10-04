# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Devise::Strategies::LdapAuthenticatable do

  let(:target) { Devise::Strategies::LdapAuthenticatable.new(nil) }
  before { target.stub(:session).and_return({}) }

  describe "#valid?" do

    context "when in the sessions controller" do
      before { target.stub(:params).and_return({ controller: "sessions" }) }

      context "if ldap_enabled?" do
        before { Site.current.update_attributes(:ldap_enabled => true) }
        it { target.valid?.should be true }
      end

      context "if not ldap_enabled?" do
        before { Site.current.update_attributes(:ldap_enabled => false) }
        it { target.valid?.should be false }
      end
    end

    context "when in another controller" do
      before { target.stub(:params).and_return({ controller: "registrations" }) }

      context "if ldap_enabled?" do
        before { Site.current.update_attributes(:ldap_enabled => true) }
        it { target.valid?.should be false }
      end

      context "if not ldap_enabled?" do
        before { Site.current.update_attributes(:ldap_enabled => false) }
        it { target.valid?.should be false }
      end
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
          let(:ldap_user1) { { anything: 1 } }
          let(:ldap_user2) { { anything: 2 } }
          before {
            filter = double(:filter)
            target.should_receive(:ldap_filter).and_return(filter)
            @ldap_mock.should_receive(:bind_as)
              .with({ :base => "ldap-treebase", :filter => filter, :password => "user-password" })
              .and_return([ldap_user1, ldap_user2])
          }

          context "and the user information is valid" do
            before {
              Mconf::LDAP.any_instance.should_receive(:validate_user)
                .with(ldap_user1, Site.current).and_return(nil)
            }

            context "and the internal structures were created successfully" do
              before {
                @user = FactoryGirl.create(:user)
                Mconf::LDAP.any_instance.should_receive(:find_or_create_user)
                  .with(ldap_user1, Site.current).and_return(@user)
              }

              it("calls and returns #success!(user)") {
                Mconf::LDAP.any_instance.stub(:set_signed_in)
                target.should_receive(:success!).with(@user).and_return("return of success!")
                target.authenticate!.should eq("return of success!")
              }

              it("sets the user as signed in in the session") {
                Mconf::LDAP.any_instance.should_receive(:set_signed_in).with(@user, @user.ldap_token)
                target.authenticate!
              }
            end

            context "but there was an error creating the internal structures" do
              before {
                @user = FactoryGirl.create(:user)
                Mconf::LDAP.any_instance.should_receive(:find_or_create_user)
                  .with(ldap_user1, Site.current).and_return(nil)
              }

              it("calls and returns #fail(message)") {
                target.should_receive(:fail).with(I18n.t('devise.strategies.ldap_authenticatable.create_failed'))
                  .and_return("return of fail")
                target.authenticate!.should eq("return of fail")
              }
            end
          end

          context "but the user information has no username" do
            before {
              Mconf::LDAP.any_instance.should_receive(:validate_user)
                .with(ldap_user1, Site.current).and_return(:username)
              Mconf::LDAP.any_instance.should_not_receive(:find_or_create_user)
            }

            it("calls and returns #fail(message)") {
              target.should_receive(:fail).with(I18n.t('devise.strategies.ldap_authenticatable.missing_username'))
                .and_return("return of fail")
              target.authenticate!.should eq("return of fail")
            }
          end

          context "but the user information has no email" do
            before {
              Mconf::LDAP.any_instance.should_receive(:validate_user)
                .with(ldap_user1, Site.current).and_return(:email)
              Mconf::LDAP.any_instance.should_not_receive(:find_or_create_user)
            }

            it("calls and returns #fail(message)") {
              target.should_receive(:fail).with(I18n.t('devise.strategies.ldap_authenticatable.missing_email'))
                .and_return("return of fail")
              target.authenticate!.should eq("return of fail")
            }
          end

          context "but the user information has no name" do
            before {
              Mconf::LDAP.any_instance.should_receive(:validate_user)
                .with(ldap_user1, Site.current).and_return(:name)
              Mconf::LDAP.any_instance.should_not_receive(:find_or_create_user)
            }

            it("calls and returns #fail(message)") {
              target.should_receive(:fail).with(I18n.t('devise.strategies.ldap_authenticatable.missing_name'))
                .and_return("return of fail")
              target.authenticate!.should eq("return of fail")
            }
          end
        end

        context "if the binding of the target user fails" do
          before {
            @ldap_mock.should_receive(:bind_as).and_return(false) # bind failed
            @ldap_mock.stub_chain(:get_operation_result, :code).and_return("ldap error code")
            @ldap_mock.stub_chain(:get_operation_result, :message).and_return("ldap error message")
          }
          it("calls and returns #fail(:invalid)") {
            target.should_receive(:fail).with(:invalid).and_return("return of fail")
            target.authenticate!.should eq("return of fail")
          }
        end
      end

      context "if the binding of the admin user fails" do
        before {
          @ldap_mock.stub_chain(:get_operation_result, :code).and_return("ldap error code")
          @ldap_mock.stub_chain(:get_operation_result, :message).and_return("ldap error message")
        }

        context "due to an error" do
          before {
            @ldap_mock.should_receive(:bind).and_return(false) # binding failed
          }
          it("calls and returns #fail(message)") {
            msg = I18n.t('devise.strategies.ldap_authenticatable.invalid_bind')
            target.should_receive(:fail).with(msg).and_return("return of fail")
            target.authenticate!.should eq("return of fail")
          }
        end

        context "due to a timeout" do
          before {
            @ldap_mock.should_receive(:bind).and_raise(Timeout::Error)
          }
          it("calls and returns #fail(message)") {
            msg = I18n.t('devise.strategies.ldap_authenticatable.invalid_bind')
            target.should_receive(:fail).with(msg).and_return("return of fail")
            target.authenticate!.should eq("return of fail")
          }
        end

        # This error is not treated by the LDAP lib, so it's raised to the app and
        # requires a rescue_from
        context "due to an LdapError" do
          before {
            @ldap_mock.should_receive(:bind).and_raise(Net::LDAP::LdapError)
          }
          it("calls and returns #fail(message)") {
            msg = I18n.t('devise.strategies.ldap_authenticatable.invalid_bind')
            target.should_receive(:fail).with(msg).and_return("return of fail")
            target.authenticate!.should eq("return of fail")
          }
        end
      end
    end

    context "if LDAP is not enabled" do
      before {
        Site.current.update_attributes(:ldap_enabled => false)
      }
      it("calls and returns #fail(message)") {
        msg = I18n.t('devise.strategies.ldap_authenticatable.ldap_not_enabled')
        target.should_receive(:fail).with(msg).and_return("return of fail")
        target.authenticate!.should eq("return of fail")
      }
    end

    context "if LDAP is enabled but there's no user information in the params" do
      before {
        Site.current.update_attributes(:ldap_enabled => true)
        target.stub(:params).and_return({ :anything => 1 })
      }
      it("calls and returns #fail(:invalid)") {
        target.should_receive(:fail).with(:invalid).and_return("return of fail")
        target.authenticate!.should eq("return of fail")
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
    context "with a valid base filter configured" do
      let(:params) { { :user => { :login => "user-login", :password => "user-password" } } }
      let(:configs) {
        u = Object.new
        u.stub(:ldap_username_field).and_return("username")
        u.stub(:ldap_email_field).and_return("mail")
        u.stub(:ldap_filter).and_return("(&(objectclass=user)(objectcategory=person))")
        u
      }
      let(:expected) {
        Net::LDAP::Filter.construct("(&(&(objectclass=user)(objectcategory=person))(|(mail=user-login)(username=user-login)))")
      }
      before { target.stub(:params).and_return(params) }
      it { target.ldap_filter(configs).should eq(expected) }
    end

    context "without a base filter configured" do
      let(:params) { { :user => { :login => "user-login", :password => "user-password" } } }
      let(:configs) {
        u = Object.new
        u.stub(:ldap_username_field).and_return("username")
        u.stub(:ldap_email_field).and_return("mail")
        u.stub(:ldap_filter).and_return(nil)
        u
      }
      let(:expected) {
        Net::LDAP::Filter.construct("(|(mail=user-login)(username=user-login))")
      }
      before { target.stub(:params).and_return(params) }
      it { target.ldap_filter(configs).should eq(expected) }
    end

    context "with an invalid base filter" do
      let(:params) { { :user => { :login => "user-login", :password => "user-password" } } }
      let(:configs) {
        u = Object.new
        u.stub(:ldap_username_field).and_return("username")
        u.stub(:ldap_email_field).and_return("mail")
        u.stub(:ldap_filter).and_return("anything weird and invalid")
        u
      }
      let(:expected) {
        Net::LDAP::Filter.construct("(|(mail=user-login)(username=user-login))")
      }
      before { target.stub(:params).and_return(params) }
      it { target.ldap_filter(configs).should eq(expected) }
    end

    context "with an empty base filter" do
      let(:params) { { :user => { :login => "user-login", :password => "user-password" } } }
      let(:configs) {
        u = Object.new
        u.stub(:ldap_username_field).and_return("username")
        u.stub(:ldap_email_field).and_return("mail")
        u.stub(:ldap_filter).and_return("")
        u
      }
      let(:expected) {
        Net::LDAP::Filter.construct("(|(mail=user-login)(username=user-login))")
      }
      before { target.stub(:params).and_return(params) }
      it { target.ldap_filter(configs).should eq(expected) }
    end
  end

  describe "#ldap_enabled?" do
    context "if LDAP is enabled in the current site" do
      before { Site.current.update_attributes(:ldap_enabled => true) }
      it("returns true") { target.ldap_enabled?.should be_truthy }
    end

    context "if LDAP is disabled in the current site" do
      before { Site.current.update_attributes(:ldap_enabled => false) }
      it("returns false") { target.ldap_enabled?.should be_falsey }
    end
  end

  describe "#ldap_connection" do
    context "if using port 636" do
      it "returns an instance of Net::LDAP with the correct host and port and set to use simple_tls"
    end
    context "if the port is not 636" do
      it "returns an instance of Net::LDAP with the correct host and port, without simple_tls"
    end
  end

end
