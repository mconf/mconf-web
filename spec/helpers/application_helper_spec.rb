# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

include Devise::TestHelpers

describe ApplicationHelper do

  describe "#application_version" do
    it("returns the version set on the Mconf object") { application_version.should eq(Mconf::VERSION) }
  end

  describe "#application_revision" do
    before { Mconf.should_receive(:application_revision).and_return('revision') }
    it("returns Mconf.application_revision") { application_revision.should eq('revision') }
  end

  describe "#application_branch" do
    before { Mconf.should_receive(:application_branch).and_return('branch') }
    it("returns Mconf.application_branch") { application_branch.should eq('branch') }
  end

  describe "#asset_exists?" do
    it "returns whether an asset file exists"
  end

  describe "#javascript_include_tag_for_controller" do
    it "includes a javascript tag for the current controller"
    it "doesn't include anything if the target javascript doesn't exist"
  end

  describe "#stylesheet_include_tag_for_controller" do
    it "includes a stylesheet tag for the current controller"
    it "doesn't include anything if the target stylesheet doesn't exist"
  end

  describe "#controller_name_for_view" do
    before { params[:controller] = 'devise/sessions' }
    it("returns the current controller name parameterized") {
      controller_name_for_view.should eq('devise-sessions')
    }
  end

  describe "#render_page_title" do
    it "renders the page title partial with the parameters passed"
  end

  describe "#render_sidebar_content_block" do
    it "renders the sidebar content block partial with the parameters passed"
  end

  describe "#at_home?" do
    context "true if at MyController#home" do
      before {
        params[:controller] = 'my'
        params[:action] = 'home'
      }
      it { at_home?.should be_truthy }
    end

    context "false if in other action of MyController than #home" do
      before {
        params[:controller] = 'my'
        params[:action] = 'recordings'
      }
      it { at_home?.should be_falsey }
    end

    context "false if in other controller than MyController" do
      before {
        params[:controller] = 'sessions'
        params[:action] = 'home'
      }
      it { at_home?.should be_falsey }
    end
  end

  describe "#webconf_url_prefix" do
    context "returns the prefix for web conference urls" do
      before { Site.current.update_attributes(:domain => 'test.com', :ssl => true) }
      it { webconf_url_prefix.should eq('https://test.com/webconf/') }
    end
  end

  describe "#webconf_path_prefix" do
    context "returns the path prefix for web conference urls" do
      before { Site.current.update_attributes(:domain => 'test.com', :ssl => true) }
      it { webconf_path_prefix.should eq('/webconf/') }
    end
  end

  describe "#options_for_tooltip" do
    context "returns a hash with the default attributes for tooltips" do
      subject { options_for_tooltip('my-title') }
      it { subject.should be_a(Hash) }
      it('adds a title') { subject.should have_key(:title) }
      it('adds the title specified') { subject[:title].should eq('my-title') }
      it('adds classes') { subject.should have_key(:class) }
      it('adds the class tooltipped') { subject[:class].split(' ').should include('tooltipped') }
      it('adds data-placement') { subject.should have_key(:'data-placement') }
      it('data-placement defaults to top') { subject[:'data-placement'].should eq('top') }
    end

    context "includes the classes passed in the arguments" do
      subject { options_for_tooltip('my-title', { :class => 'first second' }) }
      it('adds the tooltip class') { subject[:class].split(' ').should include('tooltipped') }
      it('adds the base class `first`') { subject[:class].split(' ').should include('first') }
      it('adds the base class `second`') { subject[:class].split(' ').should include('second') }
    end

    context "uses the data-placement passed in the arguments" do
      subject { options_for_tooltip('my-title', { :'data-placement' => 'bottom' }) }
      it('data-placement defaults to top') { subject[:'data-placement'].should eq('bottom') }
    end
  end

  describe "#user_signed_in_via_federation?" do
    context "if signed in in devise and Mconf::Shibboleth" do
      before {
        should_receive(:user_signed_in?).and_return(true)
        Mconf::Shibboleth.any_instance.should_receive(:signed_in?).and_return(true)
      }
      it { user_signed_in_via_federation?.should be_truthy }
    end

    context "if there's no user signed in" do
      before { should_receive(:user_signed_in?).and_return(false) }
      it { user_signed_in_via_federation?.should be_falsey }
    end

    context "if there's a user signed in but not via federation" do
      before {
        should_receive(:user_signed_in?).and_return(true)
        Mconf::Shibboleth.any_instance.should_receive(:signed_in?).and_return(false)
      }
      it { user_signed_in_via_federation?.should be_falsey }
    end
  end

  describe "#user_signed_in_via_ldap?" do
    context "if signed in in devise and Mconf::LDAP" do
      before {
        should_receive(:user_signed_in?).and_return(true)
        Mconf::LDAP.any_instance.should_receive(:signed_in?).and_return(true)
      }
      it { user_signed_in_via_ldap?.should be_truthy }
    end

    context "if there's no user signed in" do
      before { should_receive(:user_signed_in?).and_return(false) }
      it { user_signed_in_via_ldap?.should be_falsey }
    end

    context "if there's a user signed in but not via LDAP" do
      before {
        should_receive(:user_signed_in?).and_return(true)
        Mconf::LDAP.any_instance.should_receive(:signed_in?).and_return(false)
      }
      it { user_signed_in_via_ldap?.should be_falsey }
    end
  end

  describe "#format_date" do
    it "returns the date formatted to show in a view"
    it "returns a localized string"
  end

end
