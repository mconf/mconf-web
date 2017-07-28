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

  before { Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
           Mconf::Iugu.stub(:update_customer).and_return(true) }
  let(:iugu_plan) { FactoryGirl.create(:plan) }

  describe "#create_customer_and_sub" do

    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, user_id: 1, plan_id: iugu_plan.id) }
      before { Mconf::Iugu.stub(:create_customer).and_return(nil) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:ops_error) }
    end

    context "invalid cpf/cnpj" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, cpf_cnpj: "1234", user_id: 1, plan_id: iugu_plan.id) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"cpf_cnpj"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:cpf_cnpj) }
    end

    context "invalid zipcode" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, zipcode: "1234", user_id: 1, plan_id: iugu_plan.id) }
      before { Mconf::Iugu.stub(:create_customer).and_return({"zip_code"=>["não é válido"]}) }
      subject { Subscription.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:zipcode) }
    end

    context "invalid cpf/cnpj and zipcode" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, cpf_cnpj: "1234", zipcode: "1234", user_id: 1, plan_id: iugu_plan.id) }
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

    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:subscription, customer_token: nil, subscription_token: nil, user_id: 1, plan_id: iugu_plan.id) }
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

  #describe "#get_sub_data" do
  #end

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

  describe "#create_invoice" do
    let!(:subscription) { FactoryGirl.create(:subscription) }

    context "failed to retrieve stats" do
      before { subscription.stub(:get_stats_for_subscription).and_return(nil)
               Mconf::Iugu.stub(:add_invoice_item).and_return(false) }
      it { expect { subscription.create_invoice }.to raise_error("get_stats error") }
    end

    context "successful create_invoice" do
      before { subscription.stub(:get_stats_for_subscription).and_return({:returncode=>true, :stats=>{:meeting=>{:meetingID=>"meetid", :meetingName=>"meet-name", :recordID=>"rec-id",
                                                                          :epochStartTime=>"1501267120992", :startTime=>"10879193200", :endTime=>"10879245167", :participants=>{:participant=>
                                                                          [{:userID=>"veq7rb6lc7rq_2", :externUserID=>"4", :userName=>"Henry Fuller", :joinTime=>"10879193200", :leftTime=>"10879245167"},
                                                                          {:userID=>"ppseriskdzip_2", :externUserID=>"ppseriskdzip", :userName=>"adfsdfa", :joinTime=>"10879237199", :leftTime=>"10879245167"}]}}},
                                                                          :messageKey=>"", :message=>""})
               Mconf::Iugu.stub(:add_invoice_item).and_return(false) }
      it { expect { subscription.create_invoice }.not_to raise_error }
    end

  end

end