# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
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

  describe "#save_to_session" do
    let(:session) { {} }
    let(:shibboleth) { Mconf::Shibboleth.new(session) }

    context "saves the variables in the environment to the session" do
      let(:env) { { :'shib-var1' => 'first', :'shib-var2' => 'second' } }
      before { shibboleth.save_to_session(env) }
      it { session.length.should be(1) }
      it { session.should have_key(:shib_data) }
      it { session[:shib_data].length.should be(2) }
      it { session[:shib_data].should have_key('shib-var1') }
      it { session[:shib_data]['shib-var1'].should eq('first') }
      it { session[:shib_data].should have_key('shib-var2') }
      it { session[:shib_data]['shib-var2'].should eq('second') }
    end

    context "if no filters are passed, uses /^shib-/" do
      let(:env) { { :'shib-var1' => 'first', :anything => 'anything', :'other-shib-invalid' => 'anything' } }
      before { shibboleth.save_to_session(env) }
      it { session[:shib_data].length.should be(1) }
      it { session[:shib_data].should have_key('shib-var1') }
      it { session[:shib_data]['shib-var1'].should eq('first') }
    end

    context "accepts string filters" do
      let(:env) { { :first => 'first', :second => 'second' } }
      before { shibboleth.save_to_session(env, 'second') }
      it { session[:shib_data].length.should be(1) }
      it { session[:shib_data].should have_key('second') }
      it { session[:shib_data]['second'].should eq('second') }
    end

    context "accepts keys as strings" do
      let(:env) { { 'first' => 'first', 'second' => 'second' } }
      before { shibboleth.save_to_session(env, 'second') }
      it { session[:shib_data].length.should be(1) }
      it { session[:shib_data].should have_key('second') }
      it { session[:shib_data]['second'].should eq('second') }
    end

    context "accepts regex filters" do
      let(:env) { { :any_one => 'first', :any_two => 'second', :other_any => 'third' } }
      before { shibboleth.save_to_session(env, 'any.*') }
      it { session[:shib_data].length.should be(2) }
      it { session[:shib_data].should have_key('any_one') }
      it { session[:shib_data]['any_one'].should eq('first') }
      it { session[:shib_data].should have_key('any_two') }
      it { session[:shib_data]['any_two'].should eq('second') }
    end

    context "transform filters into exact regexes" do
      let(:env) { { :pre => 'first', :prefix => 'second', :preamble => 'third' } }
      before { shibboleth.save_to_session(env, 'pre') }
      it { session[:shib_data].length.should be(1) }
      it { session[:shib_data].should have_key('pre') }
      it { session[:shib_data]['pre'].should eq('first') }
    end

    context "accepts multiple filters separated by '\\n' or '\\r\\n'" do
      let(:env) { { :first => 'first', :second => 'second', :second_b => 'second_b', :third => 'third', :fourth => 'fourth' } }
      before { shibboleth.save_to_session(env, "first\nsecond.*\r\nthird") }
      it { session[:shib_data].length.should be(4) }
      it { session[:shib_data].should have_key('first') }
      it { session[:shib_data]['first'].should eq('first') }
      it { session[:shib_data].should have_key('second') }
      it { session[:shib_data]['second'].should eq('second') }
      it { session[:shib_data].should have_key('second_b') }
      it { session[:shib_data]['second_b'].should eq('second_b') }
      it { session[:shib_data].should have_key('third') }
      it { session[:shib_data]['third'].should eq('third') }
    end

    context "ignores cases in the filters" do
      let(:env) { { :firsT => 'first', :second => 'second' } }
      before { shibboleth.save_to_session(env, 'FiRsT') }
      it { session[:shib_data].length.should be(1) }
      it { session[:shib_data].should have_key('firsT') }
      it { session[:shib_data]['firsT'].should eq('first') }
    end

    context "ignores white spaces in the front and end of filters" do
      let(:env) { { :first => 'first', :second => 'second' } }
      before { shibboleth.save_to_session(env, '   first   ') }
      it { session[:shib_data].length.should be(1) }
      it { session[:shib_data].should have_key('first') }
      it { session[:shib_data]['first'].should eq('first') }
    end

    context "returns the data stored in the session" do
      let(:env) { { :first => 'first', :second => 'second' } }
      before { @result = shibboleth.save_to_session(env, "first\nsecond") }
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
      it { should be_false }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }
      subject { shibboleth.has_basic_info }

      context "returns false if the email is not there" do
        let(:session) { { :shib_data => {} } }
        it { should be_false }
      end

      context "returns false if the name is not there" do
        let(:session) { { :shib_data => {} } }
        it { should be_false }
      end

      context "returns true if name and email are there" do
        let(:session) { { :shib_data => { 'email' => "anything", 'name' => "anything" } } }
        before {
          Site.current.update_attributes(:shib_email_field => 'email', :shib_name_field => 'name')
        }
        it { should be_true }
      end
    end

  end

  describe "#get_email" do
    context "returns nil if there's no shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new({}) }
      subject { shibboleth.get_email }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }

      context "returns the email pointed by the site's 'shib_email_field'" do
        let(:session) { { :shib_data => { 'email' => 'my-email@anything' } } }
        subject { shibboleth.get_email }
        before {
          Site.current.update_attributes(:shib_email_field => 'email')
        }
        it { should eq('my-email@anything') }
      end

      context "if 'shib_email_field' is not set, uses a default key" do
        let(:session) { { :shib_data => { 'Shib-inetOrgPerson-mail' => 'my-email@anything' } } }
        subject { shibboleth.get_email }
        before {
          Site.current.update_attributes(:shib_email_field => nil)
        }
        it { should eq('my-email@anything') }
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
      subject { shibboleth.get_name }
      it { should be_nil }
    end

    context "when there's shib data in the session" do
      let(:shibboleth) { Mconf::Shibboleth.new(session) }

      context "returns the name pointed by the site's 'shib_name_field'" do
        let(:session) { { :shib_data => { 'name' => 'my-name' } } }
        subject { shibboleth.get_name }
        before {
          Site.current.update_attributes(:shib_name_field => 'name')
        }
        it { should eq('my-name') }
      end

      context "if 'shib_name_field' is not set, uses a default key" do
        let(:session) { { :shib_data => { 'Shib-inetOrgPerson-cn' => 'my-name' } } }
        subject { shibboleth.get_name }
        before {
          Site.current.update_attributes(:shib_name_field => nil)
        }
        it { should eq('my-name') }
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

end
