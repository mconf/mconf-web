# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Invoice do
  it { should validate_presence_of(:subscription_id)      }
  it { should validate_presence_of(:due_date)             }
  it { should validate_presence_of(:flag_invoice_status)  }


  skip "calculate the invoice value"
  skip "test posting the invoice value"
  skip "get the data from the csv for unique users"

  describe "create" do
    context "Create an invoice for a subscription" do
      let(:subscription) { FactoryGirl.create(:subscription) }
      subject { subscription.invoices.create(due_date: DateTime.now.change({day: 10}), flag_invoice_status: "local") }
      it { expect { subject }.to change{ Invoice.count }.by(1) }
    end
  end

  describe "get the invoices data (url and token)" do
    skip "stub return from ops and check flags update"
  end

  describe "values generated for invoice#show are correct" do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
    let(:target) { FactoryGirl.create(:invoice, subscription_id: subscription.id) }

    before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3, :days=>0.7333333333333333},
                                       :quantity=>1000, :cost_per_user=>600, :total=>308000.0, :minimum=>false}) }

    context "invoice_full_price" do
      it { target.invoice_full_price.should eql("+ R$ 6000.00")}
    end

    context "invoice_users_discount" do
      it { target.invoice_users_discount.should eql("- R$ 1800.00")}
    end

    context "invoice_days_discount" do
      it { target.invoice_days_discount.should eql("- R$ 1120.00")}
    end

    context "invoice_total" do
      it { target.invoice_total.should eql("R$ 3080.00")}
    end
  end

  context "#next_due_date" do
    it { Invoice.next_due_date.should eql((DateTime.now.change({day: Rails.application.config.due_day})+1.month).beginning_of_day) }
  end

  describe "file routes are generated correctly" do
    let(:user) { FactoryGirl.create(:user) }
    let(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
    let(:target) { FactoryGirl.create(:invoice, subscription_id: subscription.id) }

    context "#report_file_path" do
      it { target.report_file_path.should eql("/vagrant/private/subscriptions/#{(target.due_date-1.month).strftime("%Y-%m")}/#{user.id}/report-en.pdf") }
    end
    context "#csv_file_path" do
      it { target.csv_file_path.should eql("/vagrant/private/subscriptions/#{(target.due_date-1.month).strftime("%Y-%m")}/#{user.id}/unique-users.csv") }
    end
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:report])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "an user on his own invoice page" do
      let(:user) { FactoryGirl.create(:user) }
      let(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
      let(:target) { FactoryGirl.create(:invoice, subscription_id: subscription.id) }
      it { should_not be_able_to_do_anything_to(target).except([:show, :report]) }
    end

    context "an user on another user's invoice" do
      let(:user) { FactoryGirl.create(:user) }
      let(:target) { FactoryGirl.create(:invoice) }
      it { should_not be_able_to_do_anything_to(target) }
    end

  end
end