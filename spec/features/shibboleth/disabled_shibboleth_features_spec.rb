# coding: utf-8
require 'spec_helper'

describe 'Disabled shibboleth features' do
  let(:ufrgsVinculo) { "ativo:12:Funcionário de Fundações da UFRGS:1:Instituto de Informática:NULL:NULL:NULL:NULL:01/01/2011:NULL;" }
  subject { page }
  before(:all) {
    @attrs = FactoryGirl.attributes_for(:user, :email => "user@mconf.org")
  }

  context "an user account created via shibboleth" do
    before {
      enable_shib
      Site.current.update_attributes :shib_always_new_account => true

      setup_shib @attrs[:_full_name], @attrs[:email], @attrs[:email], ufrgsVinculo

      visit shibboleth_path
    }

    context "shouldn't see password fields in edit screen" do
      before { visit edit_user_path(ShibToken.last.user) }

      it { page.should_not have_field("user_current_password") }
      it { page.should_not have_field("user_password") }
      it { page.should_not have_field("user_password_confirmation") }
    end
  end
end
