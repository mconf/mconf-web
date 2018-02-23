# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Shibboleth do

  #subject { Mconf::Shibboleth.new }

  describe "#initialize" do
    context "receives and stores a `session` object" do
      let(:expected) { "anything" }
      subject { Mconf::Shibboleth.new(expected) }
      it { subject.instance_variable_get("@session").should eq(expected) }
    end
  end

  describe "#load_data" do
    let(:session) { {} }
    let(:shibboleth) { Mconf::Shibboleth.new(session) }

    context "saves the variables in the environment to the session" do
      let(:env) { { :'shib-var1' => 'first', :'shib-var2' => 'second' } }
      before { shibboleth.load_data(env) }
      it { shibboleth.get_data.length.should be() }
      it { shibboleth.get_data.length.should be(2) }
      it { shibboleth.get_data.should have_key('shib-var1') }
      it { shibboleth.get_data['shib-var1'].should eq('first') }
      it { shibboleth.get_data.should have_key('shib-var2') }
      it { shibboleth.get_data['shib-var2'].should eq('second') }
    end

    context "if no filters are passed, uses /^shib-/" do
      let(:env) { { :'shib-var1' => 'first', :anything => 'anything', :'other-shib-invalid' => 'anything' } }
      before { shibboleth.load_data(env) }
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('shib-var1') }
      it { shibboleth.get_data['shib-var1'].should eq('first') }
    end

    context "accepts string filters" do
      let(:env) { { :first => 'first', :second => 'second' } }
      before { shibboleth.load_data(env, 'second') }
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('second') }
      it { shibboleth.get_data['second'].should eq('second') }
    end

    context "string with encoding ASCII-8BIT" do
      let(:env) { { :first => 'first', :second => 'çÃïçáõ'.force_encoding("ASCII-8BIT") } }
      before { shibboleth.load_data(env, 'second')}
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('second') }
      it { shibboleth.get_data['second'].should eq('çÃïçáõ') }
    end

    context "accepts keys as strings" do
      let(:env) { { 'first' => 'first', 'second' => 'second' } }
      before { shibboleth.load_data(env, 'second') }
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('second') }
      it { shibboleth.get_data['second'].should eq('second') }
    end

    context "accepts regex filters" do
      let(:env) { { :any_one => 'first', :any_two => 'second', :other_any => 'third' } }
      before { shibboleth.load_data(env, 'any.*') }
      it { shibboleth.get_data.length.should be(2) }
      it { shibboleth.get_data.should have_key('any_one') }
      it { shibboleth.get_data['any_one'].should eq('first') }
      it { shibboleth.get_data.should have_key('any_two') }
      it { shibboleth.get_data['any_two'].should eq('second') }
    end

    context "transform filters into exact regexes" do
      let(:env) { { :pre => 'first', :prefix => 'second', :preamble => 'third' } }
      before { shibboleth.load_data(env, 'pre') }
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('pre') }
      it { shibboleth.get_data['pre'].should eq('first') }
    end

    context "accepts multiple filters separated by '\\n' or '\\r\\n'" do
      let(:env) { { :first => 'first', :second => 'second', :second_b => 'second_b', :third => 'third', :fourth => 'fourth' } }
      before { shibboleth.load_data(env, "first\nsecond.*\r\nthird") }
      it { shibboleth.get_data.length.should be(4) }
      it { shibboleth.get_data.should have_key('first') }
      it { shibboleth.get_data['first'].should eq('first') }
      it { shibboleth.get_data.should have_key('second') }
      it { shibboleth.get_data['second'].should eq('second') }
      it { shibboleth.get_data.should have_key('second_b') }
      it { shibboleth.get_data['second_b'].should eq('second_b') }
      it { shibboleth.get_data.should have_key('third') }
      it { shibboleth.get_data['third'].should eq('third') }
    end

    context "ignores cases in the filters" do
      let(:env) { { :firsT => 'first', :second => 'second' } }
      before { shibboleth.load_data(env, 'FiRsT') }
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('firsT') }
      it { shibboleth.get_data['firsT'].should eq('first') }
    end

    context "ignores white spaces in the front and end of filters" do
      let(:env) { { :first => 'first', :second => 'second' } }
      before { shibboleth.load_data(env, '   first   ') }
      it { shibboleth.get_data.length.should be(1) }
      it { shibboleth.get_data.should have_key('first') }
      it { shibboleth.get_data['first'].should eq('first') }
    end

    context "returns the data stored in the session" do
      let(:env) { { :first => 'first', :second => 'second' } }
      before { @result = shibboleth.load_data(env, "first\nsecond") }
      it { @result.length.should be(2) }
      it { @result.should have_key('first') }
      it { @result['first'].should eq('first') }
      it { @result.should have_key('second') }
      it { @result['second'].should eq('second') }
    end

  end

  describe "#has_basic_info" do

    context "returns false if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      subject { shibboleth.has_basic_info }
      it { should be_falsey }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before {
        shibboleth.set_data(session[:shib_data])

        Site.current.update_attributes(:shib_email_field => 'email',
                                       :shib_name_field => 'name',
                                       :shib_principal_name_field => 'principal_name')
      }
      subject { shibboleth.has_basic_info }

      context "returns false if the email is not there" do
        let(:session) { { :shib_data => { "name" => "anything", "principal_name" => "anything" } } }
        it { should be(false) }
      end

      context "returns false if the name is not there" do
        let(:session) { { :shib_data => { "email" => "anything", "principal_name" => "anything" } } }
        it { should be(false) }
      end

      context "returns false if the principal name is not there" do
        let(:session) { { :shib_data => { "email" => "anything", "name" => "anything" } } }
        it { should be(false) }
      end

      context "returns true if name and email are there" do
        let(:session) { { :shib_data => { 'email' => "anything", 'name' => "anything", "principal_name" => "anything" } } }
        it { should be(true) }
      end
    end

  end

  describe "#get_email" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      before { shibboleth.load_data({}) }
      subject { shibboleth.get_email }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before { shibboleth.set_data(session[:shib_data]) }

      context "returns the email pointed by the site's 'shib_email_field'" do
        let(:session) { { :shib_data => { 'email' => 'my-email@anything' } } }
        subject { shibboleth.get_email }
        before {
          Site.current.update_attributes(:shib_email_field => 'email')
        }
        it { should eq('my-email@anything') }
      end

      context "if 'shib_email_field' is not set, returns nil" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_email }
        before {
          Site.current.update_attributes(:shib_email_field => nil)
        }
        it { should be_nil }
      end

      context "returns nil if the email is not set" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_email }
        before {
          Site.current.update_attributes(:shib_email_field => 'email')
        }
        it { should be_nil }
      end

      # see issue #973
      context "clones the result string to prevent it from being modified" do
        let(:original) { 'my-email@anything' }
        let(:session) { { :shib_data => { 'email' => original } } }
        before {
          Site.current.update_attributes(:shib_email_field => 'email')
          @subject = shibboleth.get_email

          # something that would alter the string pointed by it
          @subject.gsub!(/my-email/, 'altered-email')
        }
        it { @subject.should eq('altered-email@anything') }
        it { original.should eq('my-email@anything') }
      end
    end

  end

  describe "#get_name" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      before { shibboleth.set_data({}) }
      subject { shibboleth.get_name }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before { shibboleth.set_data(session[:shib_data]) }

      context "returns the name pointed by the site's 'shib_name_field'" do
        let(:session) { { :shib_data => { 'name' => 'my-name' } } }
        subject { shibboleth.get_name }
        before {
          Site.current.update_attributes(:shib_name_field => 'name')
        }
        it { should eq('my-name') }
      end

      context "if 'shib_name_field' is not set, returns nil" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_name }
        before {
          Site.current.update_attributes(:shib_name_field => nil)
        }
        it { should be_nil }
      end

      context "returns nil if the name is not set" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_name }
        before {
          Site.current.update_attributes(:shib_name_field => 'name')
        }
        it { should be_nil }
      end

      # see issue #973
      context "clones the result string to prevent it from being modified" do
        let(:original) { 'my-name' }
        let(:session) { { :shib_data => { 'name' => original } } }
        before {
          Site.current.update_attributes(:shib_name_field => 'name')
          @subject = shibboleth.get_name

          # something that would alter the string pointed by it
          @subject.gsub!(/my-name/, 'altered-name')
        }
        it { @subject.should eq('altered-name') }
        it { original.should eq('my-name') }
      end
    end
  end

  describe "#get_principal_name" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      before { shibboleth.set_data({}) }
      subject { shibboleth.get_principal_name }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before { shibboleth.set_data(session[:shib_data]) }

      context "returns the name pointed by the site's 'shib_principal_name_field'" do
        let(:session) { { :shib_data => { 'principal_name' => 'my-name' } } }
        subject { shibboleth.get_principal_name }
        before {
          Site.current.update_attributes(:shib_principal_name_field => 'principal_name')
        }
        it { should eq('my-name') }
      end

      context "if 'shib_name_field' is not set, returns nil" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_principal_name }
        before {
          Site.current.update_attributes(:shib_principal_name_field => nil)
        }
        it { should be_nil }
      end

      context "returns nil if the name is not set" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_principal_name }
        before {
          Site.current.update_attributes(:shib_principal_name_field => 'name')
        }
        it { should be_nil }
      end

      # see issue #973
      context "clones the result string to prevent it from being modified" do
        let(:original) { 'my-name' }
        let(:session) { { :shib_data => { 'principal_name' => original } } }
        before {
          Site.current.update_attributes(:shib_principal_name_field => 'principal_name')
          @subject = shibboleth.get_principal_name

          # something that would alter the string pointed by it
          @subject.gsub!(/my-name/, 'altered-name')
        }
        it { @subject.should eq('altered-name') }
        it { original.should eq('my-name') }
      end
    end
  end

  describe "#get_login" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      before { shibboleth.set_data({}) }
      subject { shibboleth.get_login }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before { shibboleth.set_data(session[:shib_data]) }

      context "returns the login pointed by the site's 'shib_login_field'" do
        let(:session) { { :shib_data => { 'login' => 'my-login' } } }
        subject { shibboleth.get_login }
        before {
          Site.current.update_attributes(:shib_login_field => 'login')
        }
        it { should eq('my-login') }
      end

      context "if 'shib_login_field' is not set, uses the name" do
        let(:session) { { :shib_data => { 'name' => 'my-name' } } }
        subject { shibboleth.get_login }
        before {
          Site.current.update_attributes(:shib_login_field => nil)
          Site.current.update_attributes(:shib_name_field => 'name')
        }
        it { should eq('my-name') }
      end

      context "returns nil if the login is not set" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_login }
        it { should be_nil }
      end

      # see issue #973
      context "clones the result string to prevent it from being modified" do
        let(:original) { 'my-login' }
        let(:session) { { :shib_data => { 'login' => original } } }
        before {
          Site.current.update_attributes(:shib_login_field => 'login')
          @subject = shibboleth.get_login

          # something that would alter the string pointed by it
          @subject.gsub!(/my-login/, 'altered-login')
        }
        it { @subject.should eq('altered-login') }
        it { original.should eq('my-login') }
      end
    end

  end

  describe "#get_identity_provider" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      before { shibboleth.set_data({}) }
      subject { shibboleth.get_identity_provider }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before { shibboleth.set_data(session[:shib_data]) }

      context "returns the identity provider using a default key" do
        let(:session) { { :shib_data => { 'Shib-Identity-Provider' => 'my-idp' } } }
        subject { shibboleth.get_identity_provider }
        it { should eq('my-idp') }
      end

      context "returns nil if the identity provider is not set" do
        let(:session) { { :shib_data => { } } }
        subject { shibboleth.get_identity_provider }
        it { should be_nil }
      end

      # see issue #973
      context "clones the result string to prevent it from being modified" do
        let(:original) { 'my-idp' }
        let(:session) { { :shib_data => { 'Shib-Identity-Provider' => original } } }
        before {
          @subject = shibboleth.get_identity_provider

          # something that would alter the string pointed by it
          @subject.gsub!(/my-idp/, 'altered-idp')
        }
        it { @subject.should eq('altered-idp') }
        it { original.should eq('my-idp') }
      end
    end
  end

  describe "#get_data" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      before { shibboleth.set_data({}) }
      subject { shibboleth.get_data }
      it { should be_blank }
    end

    context "returns the data when there's shib data in the session" do
      let(:session) { { :shib_data => { 'first' => 'any', 'second' => 'other' } } }
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      before { shibboleth.set_data(session[:shib_data]) }

      subject { shibboleth.get_data }
      it { should eq(session[:shib_data]) }
    end
  end

  describe "#signed_in?" do
    context "if the session is not defined" do
      let(:shibboleth) { Mconf::Shibboleth.new(nil) }
      subject { shibboleth.signed_in? }
      it { should be(false) }
    end

    context "if the session has no #{Mconf::Shibboleth::SESSION_KEY} key" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      subject { shibboleth.signed_in? }
      it { should be(false) }
    end

    context "if the session has #{Mconf::Shibboleth::SESSION_KEY} key" do
      let(:shibboleth) { Mconf::Shibboleth.new({ "#{Mconf::Shibboleth::SESSION_KEY}" => {} }) }
      before { shibboleth.set_data({}) }

      subject { shibboleth.signed_in? }
      it { should be(false) }
    end

    context "if the session has #{Mconf::Shibboleth::SESSION_KEY} key and `set_signed_in` was called" do
      let(:shibboleth) { Mconf::Shibboleth.new({ "#{Mconf::Shibboleth::SESSION_KEY}" => {} }) }
      let(:shib_token) { FactoryGirl.create(:shib_token) }
      before {
        shibboleth.set_data({})
        shibboleth.set_signed_in(shib_token.user, shib_token)
      }

      subject { shibboleth.signed_in? }
      it { should be(true) }
    end
  end

  describe "#basic_info_fields" do
    let(:shibboleth) { Mconf::Shibboleth.new({}) }

    context "returns the attributes for name, email and principal name set in the site (if set)" do
      before {
        Site.current.update_attributes(:shib_email_field => 'email', :shib_name_field => 'name', :shib_principal_name_field => 'principal_name')
      }
      it { shibboleth.basic_info_fields.should eq(['email', 'name', 'principal_name']) }
    end

    context "returns nil if the attributes are not set in the site" do
      before {
        Site.current.update_attributes(:shib_email_field => nil, :shib_name_field => nil, :shib_principal_name_field => nil)
      }
      it { shibboleth.basic_info_fields.should eq([nil, nil, nil]) }
    end
  end

  describe "#find_token" do
    let(:shibboleth) { Mconf::Shibboleth.new({}) }
    let(:user) { FactoryGirl.create(:user) }

    context "returns the token using the information in the session" do
      before {
        ShibToken.create!(:identifier => 'any@email.com', :user => user)
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')
      }
      subject { shibboleth.find_token }
      it { subject.identifier.should eq('any@email.com') }
      it { subject.user.should eq(user) }
    end

    context "returns nil of there's no token" do
      before {
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')
      }
      subject { shibboleth.find_token }
      it { subject.should be_nil }
    end
  end

  describe "#find_and_update_token" do
    let(:shibboleth) { Mconf::Shibboleth.new({}) }
    let(:user) { FactoryGirl.create(:user) }

    context "returns the token using the information in the session" do
      before {
        ShibToken.create!(identifier: 'any@email.com', user: user)
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')
      }
      subject { shibboleth.find_and_update_token }
      it { subject.identifier.should eq('any@email.com') }
      it { subject.user.should eq(user) }
    end

    context "returns nil of there's no token" do
      before {
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')
      }
      subject { shibboleth.find_and_update_token }
      it { subject.should be_nil }
    end

    context "updates the token with the info in the session" do
      let(:old_data) { { "Shib-cn": "My Name", "Shib-id": 12345, "AnotherParam": "no value" } }
      let(:new_data) { { "Shib-cn": "New Name", "AnotherParam": 12345 } }
      let(:shibboleth) { Mconf::Shibboleth.new({ shib_data: new_data }) }
      before {
        ShibToken.create!(identifier: 'any@email.com', user: user, data: old_data)
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')

        shibboleth.set_data(new_data)
      }
      subject {
        token = shibboleth.find_and_update_token
        token.reload
        token
      }
      it { subject.data.should eq(new_data) }
    end

    context "doesn't save if there's no data in the session" do
      let(:old_data) { { "Shib-cn": "My Name", "Shib-id": 12345, "AnotherParam": "no value" } }
      let(:new_data) { nil }
      let(:shibboleth) { Mconf::Shibboleth.new({ shib_data: new_data }) }
      before {
        ShibToken.create!(identifier: 'any@email.com', user: user, data: old_data)
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')

        shibboleth.set_data(new_data)
      }
      subject {
        token = shibboleth.find_and_update_token
        token.reload
        token
      }
      it { subject.data.should eq(old_data) }
    end

    context "doesn't save if the data in the session is empty" do
      let(:old_data) { { "Shib-cn": "My Name", "Shib-id": 12345, "AnotherParam": "no value" } }
      let(:new_data) { {} }
      let(:shibboleth) { Mconf::Shibboleth.new({ shib_data: new_data }) }
      before {
        ShibToken.create!(identifier: 'any@email.com', user: user, data: old_data)
        shibboleth.should_receive(:get_identifier).and_return('any@email.com')
      }
      subject {
        token = shibboleth.find_and_update_token
        token.reload
        token
      }
      it { subject.data.should eq(old_data) }
    end

    it "returns the errors in the token if it failed to update"
  end

  describe "#find_or_create_token" do
    let(:shibboleth) { Mconf::Shibboleth.new({}) }
    let(:user) { FactoryGirl.create(:user) }

    context "returns the token using the information in the session" do
      before {
        shibboleth.should_receive(:get_identifier).at_least(:once).and_return('any@email.com')
        @token = shibboleth.find_or_create_token
        @token.user = user
        @token.save!
      }
      it { @token.should eq(ShibToken.find_by_identifier('any@email.com')) }
    end

    context "creates the token if there's no token yet" do
      before {
        shibboleth.should_receive(:get_identifier).at_least(:once).and_return('any@email.com')
      }
      subject { shibboleth.find_or_create_token }
      it { subject.should_not be_nil }
      it { subject.identifier.should eq('any@email.com') }
      it { subject.user.should be_nil }
    end
  end

  describe "#create_user" do
    let(:shibboleth) { Mconf::Shibboleth.new({}) }

    context "creates a new user" do
      let(:token) { ShibToken.new(identifier: 'any@email.com') }
      before {
        shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
        shibboleth.should_receive(:get_login).and_return('any-login')
        shibboleth.should_receive(:get_name).and_return('Any Name')
      }
      before(:each) {
        expect {
          @subject = shibboleth.create_user(token)
          token.user = @subject
          token.save!
        }.to change{ User.count }.by(1)
      }
      it { @subject.should eq(User.last) }
      it { @subject.errors.should be_empty }
      it("validates the email") { @subject.reload.email.should eq('any@email.com') }
      it("validates the username") { @subject.username.should eq('any-login') }
      it("validates the full name") { @subject.full_name.should eq('Any Name') }
      it("password should be set") { @subject.password.should_not be_nil }
      it("password should be long") { @subject.password.length.should be(32) }
      it("should be confirmed") { @subject.confirmed_at.should_not be_nil }
      it("should not be disabled") { @subject.disabled.should be_falsey }
      it("should not be a superuser") { @subject.superuser.should be_falsey }
    end

    context "parameterizes the login" do
      let(:token) { ShibToken.new(identifier: 'any@email.com') }
      before {
        shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
        shibboleth.should_receive(:get_login).and_return('My Login Áàéë (test)')
        shibboleth.should_receive(:get_name).and_return('Any Name')
      }
      subject { shibboleth.create_user token }
      it { subject.username.should eq('my-login-aaee-test') }
    end

    context "doesn't fail if the login already exists" do
      let(:token) { ShibToken.new(identifier: 'any@email.com') }
      before {
        FactoryGirl.create(:user, username: 'any-name')
        FactoryGirl.create(:user, username: 'any-name-2')
        shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
        shibboleth.should_receive(:get_login).and_return('Any Name')
        shibboleth.should_receive(:get_name).and_return('Any Name')
      }
      it {
        expect {
          user = shibboleth.create_user(token)
          user.username.should eq('any-name-3')
        }.to change{ User.count }.by(1)
      }
    end

    context "doesn't fail if the login is already used as the slug of a space" do
      let(:token) { ShibToken.new(identifier: 'any@email.com') }
      before {
        FactoryGirl.create(:space, slug: 'any-name')
        shibboleth.should_receive(:get_email).at_least(:once).and_return('any@email.com')
        shibboleth.should_receive(:get_login).and_return('Any Name')
        shibboleth.should_receive(:get_name).and_return('Any Name')
      }
      it {
        expect {
          user = shibboleth.create_user(token)
          user.username.should eq('any-name-2')
        }.to change{ User.count }.by(1)
      }
    end

    context "returns the user with errors set in it if the call to `save` generated errors" do
      let(:user) { FactoryGirl.create(:user) }
      let(:token) { ShibToken.new(identifier: 'dummy_shib@tok.en') }
      subject {
        expect {
          @user = shibboleth.create_user(token)
        }.not_to change{ User.count }
        @user
      }
      it("should return the user") { subject.should_not be_nil }
      it("user should not be saved") { subject.new_record?.should be(true) }
      it("user should not be valid") { subject.valid?.should be(false) }
      it("expects errors on email") { subject.errors.should have_key(:email) }
      it("expects errors on profile.full_name") { subject.errors.should have_key(:'profile.full_name') }
    end
  end

end
