# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Subscription do

  it { should validate_presence_of(:user_id)  }
  it { should validate_presence_of(:plan_id)  }
  it { should validate_presence_of(:pay_day)  }
  it { should validate_presence_of(:cpf_cnpj) }
  it { should validate_presence_of(:address)  }
  it { should validate_presence_of(:number)   }
  it { should validate_presence_of(:zipcode)  }
  it { should validate_presence_of(:city)     }
  it { should validate_presence_of(:province) }
  it { should validate_presence_of(:district) }
  it { should validate_presence_of(:country)  }

  before { Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number) }
  before { Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number) }

  describe "#create_customer_and_sub" do

    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, user_id: 1, plan_id: FactoryGirl.create(:plan).id) }
      before { Mconf::Iugu.stub(:create_customer).and_return(nil) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:ops_error) }
    end

    context "invalid cpf/cnpj" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, cpf_cnpj: "1234", user_id: 1, plan_id: FactoryGirl.create(:plan).id) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"cpf_cnpj"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:cpf_cnpj) }
    end

    context "invalid zipcode" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, zipcode: "1234", user_id: 1, plan_id: FactoryGirl.create(:plan).id) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"zip_code"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:zipcode) }
    end

    context "invalid cpf/cnpj and zipcode" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, cpf_cnpj: "1234", zipcode: "1234", user_id: 1, plan_id: FactoryGirl.create(:plan).id) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"zip_code"=>["não é válido"], "cpf_cnpj"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:cpf_cnpj) }
      it { subject.errors.should have_key(:zipcode) }
    end

    context "all data valid" do
      before { Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number) }
      it { expect { FactoryGirl.create(:subscription) }.to change{ Subscription.count }.by(1) }
    end
  end

  describe "#create_sub" do
  end

  describe "#update_sub" do
  end

  describe "#get_sub_data" do
  end

  describe "#destroy_sub" do
  end

  describe "#create_invoice" do
  end

end