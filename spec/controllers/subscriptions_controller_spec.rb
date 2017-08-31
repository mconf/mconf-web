# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SubscriptionsController do
  render_views
  let!(:referer) { "http://#{Site.current.domain}" }

  before { Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:update_customer).and_return(true)
           Mconf::Iugu.stub(:destroy_subscription).and_return(true)
           Mconf::Iugu.stub(:destroy_customer).and_return(true) }

  let(:user) { FactoryGirl.create(:user) }
  before(:each) { login_as(user) }

  let!(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
  it { should_authorize subscription, :show, :user_id => user.username }

  context "#show" do
    before { get :show, user_id: user.username }

    it { should render_template('show') }
    it { should render_with_layout('application') }
  end

  context "#edit" do
    before { get :edit, user_id: user.username }

    it { should render_template('edit') }
    it { should render_with_layout('application') }
  end

  context "#update" do
    before { request.env["HTTP_REFERER"] = referer
             put :update, user_id: user.username }

    it { should redirect_to(user_subscription_path(user)) }
    it { should set_flash.to(I18n.t("subscriptions.update")) }
  end

  context "#destroy" do
    before { delete :destroy, user_id: user.username }

    it { should redirect_to(my_home_path) }
    it { should set_flash.to(I18n.t("subscriptions.destroy")) }
  end

  describe "abilities", :abilities => true do
    render_views(false)
    let(:hash) { { user_id: user.username } }

    context "for a superuser", :user => "superuser" do
      let(:superuser) { FactoryGirl.create(:superuser) }
      before(:each) { login_as(superuser) }
      it { should allow_access_to(:show, hash) }
      it { should allow_access_to(:create) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:edit, hash) }
      it { should allow_access_to(:update, hash).via(:put) }
      it { should allow_access_to(:destroy, hash).via(:delete) }
    end

    context "for a normal user", :user => "normal" do
      before(:each) { login_as(user) }
      it { should allow_access_to(:show, hash) }
      it { should allow_access_to(:create) }
      it { should allow_access_to(:new) }
      it { should allow_access_to(:edit, hash) }
      it { should allow_access_to(:update, hash).via(:put) }
      it { should allow_access_to(:destroy, hash).via(:delete) }
    end


    context "for a normal user on other user", :user => "normal" do
      let(:other_user) { FactoryGirl.create(:user) }
      before(:each) { login_as(other_user) }
      it { should_not allow_access_to(:show, hash) }
      it { should allow_access_to(:create) }
      it { should allow_access_to(:new) }
      it { should_not allow_access_to(:edit, hash) }
      it { should_not allow_access_to(:update, hash).via(:put) }
      it { should_not allow_access_to(:destroy, hash).via(:delete) }
    end

    context "for an anonymous user", :user => "anonymous" do
      before { sign_out(user) }
      it { should_not allow_access_to(:show, hash) }
      it { should_not allow_access_to(:create) }
      it { should_not allow_access_to(:new) }
      it { should_not allow_access_to(:edit, hash) }
      it { should_not allow_access_to(:update, hash).via(:put) }
      it { should_not allow_access_to(:destroy, hash).via(:delete) }
    end
  end

end





