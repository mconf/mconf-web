# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SubscriptionsController do
  render_views

  before { Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:update_customer).and_return(true) }

  let(:user) { FactoryGirl.create(:user) }
  before(:each) { login_as(user) }

  let!(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
  it { should_authorize subscription, :show, :user_id => user.username }

  context "#show" do
    before { get :show, user_id: user.username }

    it { should render_template('show') }
    it { should render_with_layout('application') }
  end

end




#  describe "abilities", :abilities => true do
#    render_views(false)
#
#    context "for a superuser", :user => "superuser" do
#      let(:user) { FactoryGirl.create(:superuser) }
#      before(:each) { login_as(user) }
#      it { should allow_access_to(:users) }
#      it { should allow_access_to(:spaces) }
#    end
#
#    context "for a normal user", :user => "normal" do
#      let(:user) { FactoryGirl.create(:user) }
#      before(:each) { login_as(user) }
#      it { should_not allow_access_to(:users) }
#      it { should_not allow_access_to(:spaces) }
#    end
#
#    context "for an anonymous user", :user => "anonymous" do
#      it { should_not allow_access_to(:users) }
#      it { should_not allow_access_to(:spaces) }
#    end
#  end
#################################################################