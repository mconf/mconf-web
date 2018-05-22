# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Subscription do

  it { should validate_presence_of(:user_id)     }
  it { should validate_presence_of(:plan_token)  }
  it { should validate_presence_of(:pay_day)     }
  it { should validate_presence_of(:cpf_cnpj)    }
  it { should validate_presence_of(:address)     }
  it { should validate_presence_of(:number)      }
  it { should validate_presence_of(:zipcode)     }
  it { should validate_presence_of(:city)        }
  it { should validate_presence_of(:province)    }
  it { should validate_presence_of(:district)    }

  before {
    Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:update_customer).and_return(true)
  }

  let(:iugu_plan) { FactoryGirl.create(:plan) }

  describe ".not_on_trial" do
    let(:user_on_trial1) { FactoryGirl.create(:user, trial_expires_at: DateTime.now + 1.day) }
    let(:user_on_trial2) { FactoryGirl.create(:user, trial_expires_at: DateTime.now + 1.month) }
    let(:user_not_on_trial1) { FactoryGirl.create(:user, trial_expires_at: DateTime.now - 1.second) }
    let(:user_not_on_trial2) { FactoryGirl.create(:user, trial_expires_at: DateTime.now - 1.day) }
    let!(:expected_subscriptions) {
      [
        FactoryGirl.create(:subscription, user: user_not_on_trial1),
        FactoryGirl.create(:subscription, user: user_not_on_trial2)
      ]
    }
    let!(:not_expected_subscriptions) {
      [
        FactoryGirl.create(:subscription, user: user_on_trial1),
        FactoryGirl.create(:subscription, user: user_on_trial2)
      ]
    }
    subject { Subscription.not_on_trial }

    it { subject.count.should eql(2) }
    it {
      expected_subscriptions.each do |user|
        subject.should include(user)
      end
    }
    it {
      not_expected_subscriptions.each do |user|
        subject.should_not include(user)
      end
    }
  end

  describe "#create_customer_and_sub" do
    let(:user) { FactoryGirl.create(:user) }

    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, user_id: user.id, plan_token: iugu_plan.ops_token) }
      before { Mconf::Iugu.stub(:create_customer).and_return(nil) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:ops_error) }
    end

    context "invalid cpf/cnpj" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, cpf_cnpj: "1234", user_id: user.id, plan_token: iugu_plan.ops_token) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"cpf_cnpj"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:cpf_cnpj) }
    end

    context "invalid zipcode" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, zipcode: "1234", user_id: user.id, plan_token: iugu_plan.ops_token) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"zip_code"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:zipcode) }
    end

    context "invalid cpf/cnpj and zipcode" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, cpf_cnpj: "1234", zipcode: "1234", user_id: user.id, plan_token: iugu_plan.ops_token) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"zip_code"=>["não é válido"], "cpf_cnpj"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:cpf_cnpj) }
      it { subject.errors.should have_key(:zipcode) }
    end

    context "all data valid" do
      it { expect { FactoryGirl.create(:subscription) }.to change{ Subscription.count }.by(1) }
    end
  end

  describe "#create_sub" do
    let(:user) { FactoryGirl.create(:user) }

    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, user_id: user.id, plan_token: iugu_plan.ops_token) }
      before { Mconf::Iugu.stub(:create_subscription).and_return(nil) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:ops_error) }
    end

    context "all data valid" do
      it { expect { FactoryGirl.create(:subscription) }.to change{ Subscription.count }.by(1) }
    end
  end

  describe "#update_sub" do

    let(:subscription) { FactoryGirl.create(:subscription) }

    context "failed update" do
      before { Mconf::Iugu.stub(:update_customer).and_return(false) }
      subject { subscription.update_attributes(city: "Another city")
                subscription.save
                subscription.reload }
      it { subject.city.should_not eql("Another city") }
    end

    context "invalid cpf/cnpj" do
      before { Mconf::Iugu.stub(:update_customer).and_return({"cpf_cnpj"=>["não é válido"]}) }
      subject { subscription.update_attributes(cpf_cnpj: "1234")
                subscription.save
                subscription.reload }
      it { subject.cpf_cnpj.should_not eql("1234") }
    end

    context "invalid zipcode" do
      before { Mconf::Iugu.stub(:update_customer).and_return({"zip_code"=>["não é válido"]}) }
      subject { subscription.update_attributes(zipcode: "1234")
                subscription.save
                subscription.reload }
      it { subject.zipcode.should_not eql("1234") }
    end

    context "invalid cpf/cnpj and zipcode" do
      before { Mconf::Iugu.stub(:update_customer).and_return({"zip_code"=>["não é válido"], "cpf_cnpj"=>["não é válido"]}) }
      subject { subscription.update_attributes(cpf_cnpj: "1234", zipcode: "1234")
                subscription.save
                subscription.reload }
      it { subject.cpf_cnpj.should_not eql("1234") }
      it { subject.zipcode.should_not eql("1234") }
    end

    context "successful update" do
      before { Mconf::Iugu.stub(:update_customer).and_return(true) }
      subject { subscription.update_attributes(city: "Another city", cpf_cnpj: "875.245.576-98")
                subscription.save
                subscription.reload }
      it { subject.city.should eql("Another city") }
      it { subject.cpf_cnpj.should eql("875.245.576-98") }
    end

  end

  describe "#destroy_sub" do

    let!(:subscription) { FactoryGirl.create(:subscription) }

    context "failed destroy on Iugu" do
      before { Mconf::Iugu.stub(:destroy_subscription).and_return(false)
               Mconf::Iugu.stub(:destroy_customer).and_return(false) }
      it { expect { subscription.destroy }.to change{ Subscription.count }.by(0) }
    end

    context "successful destroy" do
      before { Mconf::Iugu.stub(:destroy_subscription).and_return(true)
               Mconf::Iugu.stub(:destroy_customer).and_return(true) }
      it { expect { subscription.destroy }.to change{ Subscription.count }.by(-1) }
    end
  end

  describe "#import_ops_subscriptions" do
    let!(:plan) { FactoryGirl.create(:plan, identifier: "base") }
    let!(:user) { FactoryGirl.create(:user, email: "shughes@flipstorm.info") }
    let!(:user_import) { FactoryGirl.create(:user, email: "import@flipstorm.info") }
    let(:present_subscription) { ::Iugu::Subscription.new(@attributes={"id"=>"ABC123456", "suspended"=>false,
                                                                       "plan_identifier"=>"base", "price_cents"=>0, "currency"=>"BRL",
                                                                       "features"=>{}, "expires_at"=>"2018-01-10", "created_at"=>"2017-10-19T13:42:48-02:00",
                                                                       "updated_at"=>"2017-10-26T16:42:12-02:00", "customer_name"=>"Diana Medina",
                                                                       "customer_email"=>"shughes@flipstorm.info", "cycled_at"=>nil, "credits_min"=>0,
                                                                       "credits_cycle"=>nil, "payable_with"=>"all", "customer_id"=>"BCDS123123123",
                                                                       "plan_name"=>"Basic Plan", "customer_ref"=>"Diana Medina", "plan_ref"=>"Basic Plan", "active"=>true,
                                                                       "in_trial"=>nil, "credits"=>0, "credits_based"=>false, "recent_invoices"=>nil,
                                                                       "subitems"=>[{"id"=>"EF62061C3FEE499782858DF5272C309D", "description"=>"Minimum service fee",
                                                                                     "quantity"=>15, "price_cents"=>600, "recurrent"=>false, "price"=>"R$ 6,00",
                                                                                     "total"=>"R$ 90,00"}],
                                                                        "logs"=>[{"id"=>"BA3993C7EAED4A0FBCC098E577D93966", "description"=>"Subscription Created",
                                                                                  "notes"=>"Subscription Created ", "created_at"=>"2017-10-19T13:42:48-02:00"}],
                                                                        "custom_variables"=>[]}) }

    let(:importable_subscription) { ::Iugu::Subscription.new(@attributes={"id"=>"654321CBA", "suspended"=>false,
                                                                          "plan_identifier"=>"base", "price_cents"=>0, "currency"=>"BRL",
                                                                          "features"=>{}, "expires_at"=>"2018-01-10", "created_at"=>"2017-10-19T13:42:48-02:00",
                                                                          "updated_at"=>"2017-10-26T16:42:12-02:00", "customer_name"=>"Diana Medina",
                                                                          "customer_email"=>"import@flipstorm.info", "cycled_at"=>nil, "credits_min"=>0,
                                                                          "credits_cycle"=>nil, "payable_with"=>"all", "customer_id"=>"ASDF123456",
                                                                          "plan_name"=>"Basic Plan", "customer_ref"=>"Diana Medina", "plan_ref"=>"Basic Plan", "active"=>true,
                                                                          "in_trial"=>nil, "credits"=>0, "credits_based"=>false, "recent_invoices"=>nil,
                                                                          "subitems"=>[{"id"=>"EF62061C3FEE499782858DF5272C309D", "description"=>"Minimum service fee",
                                                                                        "quantity"=>15, "price_cents"=>600, "recurrent"=>false, "price"=>"R$ 6,00",
                                                                                        "total"=>"R$ 90,00"}],
                                                                           "logs"=>[{"id"=>"BA3993C7EAED4A0FBCC098E577D93966", "description"=>"Subscription Created",
                                                                                     "notes"=>"Subscription Created ", "created_at"=>"2017-10-19T13:42:48-02:00"}],
                                                                           "custom_variables"=>[]}) }

    let(:customer) { ::Iugu::Customer.new(@attributes={"id"=>"BCDS123123123", "email"=>"shughes@flipstorm.info", "name"=>"Diana Medina",
                                                       "notes"=>nil, "created_at"=>"2017-10-19T13:42:47-02:00", "updated_at"=>"2017-10-19T13:42:47-02:00",
                                                       "cc_emails"=>nil, "cpf_cnpj"=>"011.354.780-31", "zip_code"=>"90040-060", "number"=>"203", "complement"=>"Casa 2",
                                                       "default_payment_method_id"=>nil, "proxy_payments_from_customer_id"=>nil, "city"=>"Porto Alegre", "state"=>"RS",
                                                       "district"=>"Farroupilha", "street"=>"Avenida Paulo Gama", "custom_variables"=>[{"name"=>"Country", "value"=>"Brazil"}]}) }

    let(:import_customer) { ::Iugu::Customer.new(@attributes={"id"=>"ASDF123456", "email"=>"import@flipstorm.info", "name"=>"Diana Medina",
                                                       "notes"=>nil, "created_at"=>"2017-10-19T13:42:47-02:00", "updated_at"=>"2017-10-19T13:42:47-02:00",
                                                       "cc_emails"=>nil, "cpf_cnpj"=>"011.354.780-31", "zip_code"=>"90040-060", "number"=>"203", "complement"=>"Casa 2",
                                                       "default_payment_method_id"=>nil, "proxy_payments_from_customer_id"=>nil, "city"=>"Porto Alegre", "state"=>"RS",
                                                       "district"=>"Farroupilha", "street"=>"Avenida Paulo Gama", "custom_variables"=>[{"name"=>"Country", "value"=>"Brazil"}]}) }

    context "the subscription already exists in our database" do
      before {
        Mconf::Iugu.stub(:fetch_all_subscriptions).and_return([present_subscription])
        Mconf::Iugu.stub(:get_subscription).and_return(present_subscription)
        Mconf::Iugu.stub(:find_customer_by_id).and_return(customer)
        Mconf::Iugu.stub(:create_subscription).and_return("ABC123456")
      }
      let!(:subscription) { FactoryGirl.create(:subscription, subscription_token: "ABC123456", user_id: user.id) }
      subject { Subscription.import_ops_subscriptions }
      it { expect { subject }.to change{ Subscription.count }.by(0) }
    end

    context "the subscription is imported correctly" do
      before {
        Mconf::Iugu.stub(:fetch_all_subscriptions).and_return([importable_subscription])
        Mconf::Iugu.stub(:get_subscription).and_return(present_subscription)
        Mconf::Iugu.stub(:find_customer_by_id).and_return(import_customer)
      }
      subject { Subscription.import_ops_subscriptions }
      it { expect { subject }.to change{ Subscription.count }.by(1) }
    end

    skip "there is no user to match"

    context "there are no plans to import from ops" do
      before { Mconf::Iugu.stub(:fetch_all_subscriptions).and_return(nil)
               Mconf::Iugu.stub(:find_customer_by_id).and_return([customer]) }
      subject { Subscription.import_ops_subscriptions }
      it { expect { subject }.to change{ Subscription.count }.by(0) }
    end
  end

  describe "abilities", :abilities => true do

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "an user on his own subscription" do
      let(:user) { FactoryGirl.create(:user) }
      let(:target) { FactoryGirl.create(:subscription, user_id: user.id) }
      it { should_not be_able_to_do_anything_to(target).except([:show, :create, :new, :edit, :update, :destroy]) }
    end

    context "an user another user's subscription" do
      let(:user) { FactoryGirl.create(:user) }
      let(:target) { FactoryGirl.create(:subscription) }
      # new and create are accessible to anyone but always use the logged user to create
      it { should_not be_able_to_do_anything_to(target).except([:new, :create]) }
    end

  end

  describe "#subscription_created_notification" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:plan) { FactoryGirl.create(:plan) }
    subject {
      with_activities do
        Subscription.create(
          plan_token: plan.ops_token,
          user_id:user.id,
          customer_token: "ASF",
          subscription_token: "ASDF",
          pay_day: "2018-01-11",
          cpf_cnpj: "011.354.780-31",
          address: "frase",
          additional_address_info: "a 5",
          number: "201",
          zipcode: "2222-22",
          city: "poa",
          province: "rs",
          district: "bla",
          country: "brazil",
          integrator: false
        )
      end
    }
    it do
      subject
      RecentActivity.last.key.should eql("subscription.created")
      RecentActivity.last.recipient_id.should eql(user.id)
    end
  end

  describe "#subscription_destroyed_notification" do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
    before { Mconf::Iugu.stub(:destroy_subscription).and_return(true)
             Mconf::Iugu.stub(:destroy_customer).and_return(true) }
    subject {
      with_activities do
        subscription.destroy
      end
    }
    it do
      subject
      RecentActivity.last.key.should eql("subscription.destroyed")
      RecentActivity.last.recipient_id.should eql(user.id)
    end
  end
end
