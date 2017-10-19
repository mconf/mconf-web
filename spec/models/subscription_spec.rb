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

  before { Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:update_customer).and_return(true) }
  let(:iugu_plan) { FactoryGirl.create(:plan) }

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

end