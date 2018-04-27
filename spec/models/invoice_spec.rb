# coding: utf-8
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

  before {
    Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:update_customer).and_return(true)
  }

  describe "create" do
    context "Create an invoice for a subscription" do
      let(:subscription) { FactoryGirl.create(:subscription) }
      subject { subscription.invoices.create(due_date: DateTime.now.change({day: 10}), flag_invoice_status: Invoice::INVOICE_STATUS[:local]) }
      it { expect { subject }.to change{ Invoice.count }.by(1) }
    end
  end

  describe "#generate_consumed_days" do
    let(:base_days) { Rails.application.config.base_month_days.to_i }
    before { Timecop.freeze(date) }
    after { Timecop.return }

    context "for a new subscription" do
      subject { target.generate_consumed_days("create") }

      context "on the 1st" do
        let(:subscription) { FactoryGirl.create(:subscription, pay_day: "2017-10-01") }
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 0, subscription_id: subscription.id) }
        let(:date) { DateTime.strptime('01/10/2017 12:00', "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(base_days - 1)
        }
      end

      context "on the 10th" do
        let(:subscription) { FactoryGirl.create(:subscription, pay_day: "2017-10-10") }
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 0, subscription_id: subscription.id) }
        let(:date) { DateTime.strptime('10/10/2017 12:00', "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(20)
        }
      end

      context "on the last day of the base days" do
        let(:subscription) { FactoryGirl.create(:subscription, pay_day: "2017-10-#{base_days}") }
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 0, subscription_id: subscription.id) }
        let(:date) { DateTime.strptime("#{base_days}/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(0)
        }
      end

      context "after the base days" do
        let(:subscription) { FactoryGirl.create(:subscription, pay_day: "2017-10-31") }
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 0, subscription_id: subscription.id) }
        let(:date) { DateTime.strptime("31/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(0)
        }
      end
    end

    context "for a cancelled subscription" do
      let(:target) { FactoryGirl.create(:invoice, days_consumed: 0) }
      let(:base_days) { Rails.application.config.base_month_days.to_i }
      subject { target.generate_consumed_days("destroy") }

      context "on the 1st" do
        let(:date) { DateTime.strptime('01/10/2017 12:00', "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(1)
        }
      end

      context "on the 10th" do
        let(:date) { DateTime.strptime('10/10/2017 12:00', "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(10)
        }
      end

      context "on the last day of the base days" do
        let(:date) { DateTime.strptime("#{base_days}/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(base_days)
        }
      end

      context "after the base days" do
        let(:date) { DateTime.strptime("31/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(base_days)
        }
      end
    end

    context "canceling the subscription the same month it was created" do
      subject { target.generate_consumed_days("destroy") }

      context "created on the 5th, canceled on the 10th" do
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 25) }
        let(:date) { DateTime.strptime('10/10/2017 12:00', "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(5)
        }
      end

      context "created on the 1st, canceled after base days" do
        let(:target) { FactoryGirl.create(:invoice, days_consumed: base_days - 1) }
        let(:date) { DateTime.strptime("#{base_days}/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(base_days - 1)
        }
      end

      context "canceled on the same day it was created" do
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 10) }
        let(:date) { DateTime.strptime("20/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(0)
        }
      end

      context "canceled one day after creating" do
        let(:target) { FactoryGirl.create(:invoice, days_consumed: 10) }
        let(:date) { DateTime.strptime("21/10/2017 12:00", "%d/%m/%Y %H:%M") }
        it {
          subject
          target.days_consumed.should eql(1)
        }
      end
    end
  end

  describe "get the data from the csv for unique users" do
    context "#update_unique_user_qty" do
      let(:target) { FactoryGirl.create(:invoice, user_qty: 0) }
      before { Invoice.any_instance.stub(:csv_file_path).and_return(File.join(Rails.root, "spec/fixtures/files/test-unique-users.csv")) }

      it "upadtes to the ammount specified in csv file (which is 55)" do
        target.update_unique_user_qty
        target.user_qty.should eql(55)
      end
    end
  end

  describe "#generate_invoice_value" do
    let(:invoice) { FactoryGirl.create(:invoice, days_consumed:nil, invoice_value: nil) }
    before { Invoice.any_instance.stub(:update_unique_user_qty) }

    describe "applies the correct percent discount for user treshold" do
      context "for 15 up to 249 users" do
        before { invoice.update_attributes(user_qty: 100) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(60000.0)
          subject.should eql({:discounts=>{}, :quantity=>100, :cost_per_user=>600, :total=>60000, :minimum=>false})
        end
      end

      context "for 250 up to 499 users" do
        before { invoice.update_attributes(user_qty: 300) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(162000.0)
          subject.should eql({:discounts=>{:users=>0.1}, :quantity=>300, :cost_per_user=>600, :total=>162000.0, :minimum=>false})
        end
      end

      context "for 500 up to 999 users" do
        before { invoice.update_attributes(user_qty: 600) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(288000.0)
          subject.should eql({:discounts=>{:users=>0.2}, :quantity=>600, :cost_per_user=>600, :total=>288000.0, :minimum=>false})
        end
      end

      context "for 1000 up to 2499 users" do
        before { invoice.update_attributes(user_qty: 1500) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(630000.0)
          subject.should eql({:discounts=>{:users=>0.3}, :quantity=>1500, :cost_per_user=>600, :total=>630000.0, :minimum=>false})
        end
      end

      context "for 2500 up to 4999 users" do
        before { invoice.update_attributes(user_qty: 3000) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(1080000.0)
          subject.should eql({:discounts=>{:users=>0.4}, :quantity=>3000, :cost_per_user=>600, :total=>1080000.0, :minimum=>false})
        end
      end

      context "for over 5000 users" do
        before { invoice.update_attributes(user_qty: 6000) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(1800000.0)
          subject.should eql({:discounts=>{:users=>0.5}, :quantity=>6000, :cost_per_user=>600, :total=>1800000.0, :minimum=>false})
        end
      end
    end

    describe "applies the correct percent discount for days consumed" do
      context "for nil days consumed" do
        before { invoice.update_attributes(days_consumed: nil, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(12000.0)
          subject.should eql({:discounts=>{}, :quantity=>20, :cost_per_user=>600, :total=>12000, :minimum=>false})
        end
      end

      context "for 0 days consumed" do
        before { invoice.update_attributes(days_consumed: 0, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(0.0)
          subject.should eql({:discounts=>{:days=>0.0}, :quantity=>20, :cost_per_user=>600, :total=>0.0, :minimum=>false})
        end
      end

      context "for 1 day consumed" do
        before { invoice.update_attributes(days_consumed: 1, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(400.0)
          subject.should eql({:discounts=>{:days=>0.03333333333333333}, :quantity=>20, :cost_per_user=>600, :total=>400.0, :minimum=>false})
        end
      end

      context "for 15 days consumed" do
        before { invoice.update_attributes(days_consumed: 15, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(6000.0)
          subject.should eql({:discounts=>{:days=>0.5}, :quantity=>20, :cost_per_user=>600, :total=>6000.0, :minimum=>false})
        end
      end

      context "for 29 days consumed" do
        before { invoice.update_attributes(days_consumed: 29, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(11600.0)
          subject.should eql({:discounts=>{:days=>0.9666666666666667}, :quantity=>20, :cost_per_user=>600, :total=>11600.0, :minimum=>false})
        end
      end

      context "for 30 days consumed" do
        before { invoice.update_attributes(days_consumed: 30, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(12000.0)
          subject.should eql({:discounts=>{}, :quantity=>20, :cost_per_user=>600, :total=>12000, :minimum=>false})
        end
      end

      context "for 31 days consumed" do
        before { invoice.update_attributes(days_consumed: 31, user_qty: 20) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(12000.0)
          subject.should eql({:discounts=>{}, :quantity=>20, :cost_per_user=>600, :total=>12000, :minimum=>false})
        end
      end
    end

    describe "applies the correct price for a minimum fee charge" do
      context "for minimum fee" do
        before { invoice.update_attributes(user_qty: 5) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(9000.0)
          subject.should eql({:discounts=>{}, :quantity=>5, :cost_per_user=>600, :total=>9000, :minimum=>true})
        end
      end

      context "for minimum fee with days consumed discount" do
        before { invoice.update_attributes(days_consumed: 15, user_qty: 5) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(4500.0)
          subject.should eql({:discounts=>{:days=>0.5}, :quantity=>5, :cost_per_user=>600, :total=>4500.0, :minimum=>true})
        end
      end
    end

    describe "applies the correct percent discount for user treshold and days consumed simultaneously" do
      context "for a combined discount" do
        before { invoice.update_attributes(days_consumed: 15, user_qty: 5000) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(750000.0)
          subject.should eql({:discounts=>{:days=>0.5, :users=>0.5}, :quantity=>5000, :cost_per_user=>600, :total=>750000.0, :minimum=>false})
        end
      end
    end

    describe "applies the correct cost for an integrator" do
      context "for a regular integrator" do
        before { invoice.update_attributes(user_qty: 15)
                 invoice.subscription.update_column(:integrator, true) }
        subject { invoice.generate_invoice_value }
        it "should update invoice value" do
          invoice.invoice_value.should eql(nil)
          subject
          invoice.invoice_value.should eql(6000.0)
          subject.should eql({:discounts=>{}, :quantity=>15, :cost_per_user=>400, :total=>6000, :minimum=>false})
        end
      end
    end
  end

  describe "post invoice to the ops #post_invoice_to_ops" do
    let(:subscription) { FactoryGirl.create(:subscription) }
    let(:invoice) { FactoryGirl.create(:invoice, subscription_id: subscription.id, days_consumed: nil) }
    let(:sub_token) { invoice.subscription.subscription_token }
    let(:subitems) { [{"id"=>"EF62061C3FEE499782858DF5272C309D", "description"=>"CONTENT", "quantity"=>000, "price_cents"=>000, "recurrent"=>false, "price"=>"R$ 0,00", "total"=>"R$ 000,00"}] }
    before { Mconf::Iugu.stub(:get_invoice_items).and_return([]) }
    #generation of invoice value will be stubbed to return all scenarios for a regular user (non-integrator)
    context "post an invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{},
                                       :quantity=>30, :cost_per_user=>600, :total=>18000.0, :minimum=>false})
               Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.user_fee', locale: invoice.subscription.user.locale), 600, 30) }

      it "posted a regular invoice" do
        invoice.post_invoice_to_ops
        invoice.flag_invoice_status.should eql(Invoice::INVOICE_STATUS[:posted])
      end
    end

    context "post an invoice with consumed days discount" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:days=>0.8},
                                       :quantity=>30, :cost_per_user=>600, :total=>14400.0, :minimum=>false})
               invoice.update_attributes(days_consumed: 24)
               Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.discount_days', percent_d: 19, qtd_d: invoice.days_consumed, locale: invoice.subscription.user.locale), 480, 30) }

      it "posted an invoice with days_consumed discount" do
        invoice.post_invoice_to_ops
      end
    end

    context "post an invoice with user treshold discount" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3},
                                       :quantity=>1005, :cost_per_user=>600, :total=>422100.0, :minimum=>false})
               Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.discount_users', percent_u: 30, locale: invoice.subscription.user.locale), 420, 1005) }

      it "posted an invoice with user_treshold discount" do
        invoice.post_invoice_to_ops
      end
    end

    context "post an invoice with user treshold and consumed days discount" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3, :days=>0.8},
                                       :quantity=>1005, :cost_per_user=>600, :total=>337680.0, :minimum=>false})
               invoice.update_attributes(days_consumed: 24)
               Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.discount_users_and_days', percent_d: 19, qtd_d: invoice.days_consumed, percent_u: 30, locale: invoice.subscription.user.locale), 336, 1005) }

      it "posted an invoice with user_treshold and days_consumed discount" do
        invoice.post_invoice_to_ops
      end
    end

    context "post a minimum fee invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{},
                                       :quantity=>5, :cost_per_user=>600, :total=>9000.0, :minimum=>true})
               Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.minimum_fee', locale: invoice.subscription.user.locale), 600, 15) }

      it "posted a minimum_fee invoice" do
        invoice.post_invoice_to_ops
      end
    end

    context "post a minimum fee with consumed days discount invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:days=>0.8},
                                       :quantity=>5, :cost_per_user=>600, :total=>7200.0, :minimum=>true})
               invoice.update_attributes(days_consumed: 24)
               Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.minimum_fee_discount_days', percent_d: 19, qtd_d: invoice.days_consumed, locale: invoice.subscription.user.locale), 480, 15) }

      it "posted a minimum_fee invoice with days_consumed discount" do
        invoice.post_invoice_to_ops
      end
    end

    context "post a minimum fee with consumed days discount invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:days=>0.8},
                                                                              :quantity=>5, :cost_per_user=>600, :total=>7200.0, :minimum=>true})
        invoice.update_attributes(days_consumed: 24)
        Mconf::Iugu.should_receive(:add_invoice_item).with(sub_token, I18n.t('.invoices.minimum_fee_discount_days', percent_d: 19, qtd_d: invoice.days_consumed, locale: invoice.subscription.user.locale), 480, 15) }

      it "posted a minimum_fee invoice with days_consumed discount" do
        invoice.post_invoice_to_ops
      end
    end

    context "doesn't fail if quantity is 0" do
      before {
        Invoice.any_instance.stub(:generate_invoice_value).and_return(
          { :discounts=>{:days=>0.8},
            :quantity=>0, :cost_per_user=>600, :total=>7200.0, :minimum=>true
          }
        )
        Mconf::Iugu.stub(:add_invoice_item)
        # no need to check anything else, just want to make sure it doesn't raise an exception
      }
      it { invoice.post_invoice_to_ops }
    end
  end

  describe "values generated for invoice#show are correct using arbitrary return" do
    let(:target) { FactoryGirl.create(:invoice) }

    before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3, :days=>0.7333333333333333},
                                       :quantity=>1000, :cost_per_user=>600, :total=>308000.0, :minimum=>false}) }

    context "#full_price_as_string" do
      it { target.full_price_as_string.should eql("R$ 6000.00")}
    end

    context "#users_discount_as_string" do
      it { target.users_discount_as_string.should eql("R$ 1800.00")}
    end

    context "#days_discount_as_string" do
      it { target.days_discount_as_string.should eql("R$ 1120.00")}
    end

    context "#total_as_string" do
      it { target.total_as_string.should eql("R$ 3080.00")}
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
      it { target.report_file_path.should eql("/vagrant/private/subscriptions/#{(target.due_date-1.month).strftime("%Y-%m")}/#{user.id}/#{Rails.application.config.report_en}") }
    end
    context "#csv_file_path" do
      it { target.csv_file_path.should eql("/vagrant/private/subscriptions/#{(target.due_date-1.month).strftime("%Y-%m")}/#{user.id}/unique-users.csv") }
    end
  end

  describe "get the invoices data (url and token)" do
    context "#get_invoice_payment_data" do
      let(:target) { FactoryGirl.create(:invoice, due_date: DateTime.civil(2017, 10, 10).utc, invoice_token: nil, invoice_url: nil) }
      let(:invoice_iugu) { ::Iugu::Subscription.new(@attributes={
        "id"=>"C963AAF1125D4AFCA1FCC83F494947FF", "due_date"=>"2017-10-10",
        "currency"=>"BRL", "discount_cents"=>nil, "email"=>"shughes@flipstorm.info",
        "notification_url"=>nil, "return_url"=>nil, "status"=>"pending", "tax_cents"=>nil,
        "updated_at"=>"2017-11-13T05:46:42-02:00", "total_cents"=>2222, "total_paid_cents"=>0,
        "paid_at"=>nil, "taxes_paid_cents"=>nil, "paid_cents"=>nil, "cc_emails"=>nil, "payable_with"=>"all",
        "overpaid_cents"=>nil, "ignore_due_email"=>true, "ignore_canceled_email"=>nil, "advance_fee_cents"=>nil,
        "commission_cents"=>nil, "early_payment_discount"=>false, "secure_id"=>"c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7",
        "secure_url"=>"https://faturas.iugu.com/c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7",
        "customer_id"=>"7A9E0083A898485F875590DFF4597549", "customer_ref"=>"Diana Medina",
        "customer_name"=>"Diana Medina", "user_id"=>nil, "total"=>"R$ 22,22", "taxes_paid"=>"R$ 0,00",
        "total_paid"=>"R$ 0,00", "total_overpaid"=>"R$ 0,00", "commission"=>"R$ 0,00", "fines_on_occurrence_day"=>nil,
        "total_on_occurrence_day"=>nil, "fines_on_occurrence_day_cents"=>nil, "total_on_occurrence_day_cents"=>nil,
        "financial_return_date"=>nil, "advance_fee"=>nil, "paid"=>"R$ 0,00", "interest"=>nil, "discount"=>nil,
        "created_at"=>"03/11, 15:26 h", "refundable"=>nil, "installments"=>nil, "transaction_number"=>1111, "payment_method"=>nil,
        "created_at_iso"=>"2017-11-03T15:26:07-02:00", "updated_at_iso"=>"2017-11-13T05:46:42-02:00", "occurrence_date"=>nil,
        "financial_return_dates"=>nil, "bank_slip"=>nil, "items"=>[{"id"=>"77081F811FE54952AE31966491760816",
        "description"=>"Teste 2", "price_cents"=>2222, "quantity"=>1, "created_at"=>"2017-11-03T15:26:07-02:00",
        "updated_at"=>"2017-11-03T15:26:07-02:00", "price"=>"R$ 22,22"}], "early_payment_discounts"=>[],
        "variables"=>[{"id"=>"8E0163AF92764E50B10FD5D5B1321004", "variable"=>"hl", "value"=>"pt-BR"},
          {"id"=>"5B85B8FB20F4462FBEF1E31B274A7C6E", "variable"=>"last_dunning_day", "value"=>"5"},
          {"id"=>"00C0A102A3D94BC8B98C940F3627A822", "variable"=>"payer.address.city", "value"=>"Porto Alegre"},
          {"id"=>"8EC87DB8238B4B7AB8CA1FB3737C7086", "variable"=>"payer.address.complement", "value"=>"Casa 2"},
          {"id"=>"EC7FECC0B27A4270B859B0A6CC12D03A", "variable"=>"payer.address.district", "value"=>"Farroupilha"},
          {"id"=>"954056171A834DE099DDB96E99F63D20", "variable"=>"payer.address.number", "value"=>"203"},
          {"id"=>"F12FA7DFE96143FAABFE690876DA3BE2", "variable"=>"payer.address.state", "value"=>"RS"},
          {"id"=>"B5D7FABF86A245768E66AE8ABFC1BC9B", "variable"=>"payer.address.street", "value"=>"Avenida Paulo Gama"},
          {"id"=>"D4CB638C2B2840BAAEA76B39D57A0977", "variable"=>"payer.address.zip_code", "value"=>"90040-060"},
          {"id"=>"92FBA7D38A7F4623A4AC344F966501FD", "variable"=>"payer.cpf_cnpj", "value"=>"011.354.780-31"},
          {"id"=>"E5D11B8E72DA4B25AA800AF074F686EA", "variable"=>"payer.name", "value"=>"Diana Medina"},
          {"id"=>"BD53D47C07F243D2B789B31B49882D6B", "variable"=>"payment_data.transaction_number", "value"=>"1111"}],
        "custom_variables"=>[], "logs"=>[{"id"=>"5D788A674E5041209371A855F8DF5CF1", "description"=>"Invoice viewed!",
          "notes"=>"Invoice viewed!", "created_at"=>"07/11, 10:50 h"}]})
      }

      before { Mconf::Iugu.stub(:fetch_user_invoices).and_return([invoice_iugu]) }
      subject { target.get_invoice_payment_data }

      it "should update the values to data from iugu ops" do
        target.invoice_url.should eql(nil)
        target.invoice_token.should eql(nil)
        subject
        target.invoice_url.should eql("https://faturas.iugu.com/c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7")
        target.invoice_token.should eql("C963AAF1125D4AFCA1FCC83F494947FF")
        target.flag_invoice_status.should eql(Invoice::INVOICE_STATUS[:pending])
      end
    end
  end

  describe "closing the invoice" do
    context "#close" do
      let(:target) { FactoryGirl.create(:invoice) }
      subject { target.close }

      it "should update the flag to closed" do
        target.flag_invoice_status.should eql(Invoice::INVOICE_STATUS[:local])
        subject
        target.flag_invoice_status.should eql(Invoice::INVOICE_STATUS[:closed])
      end
    end
  end

  describe "checking if the last invoice is already paid for" do
    context "#check_payment" do
      let(:target) { FactoryGirl.create(:invoice, flag_invoice_status: Invoice::INVOICE_STATUS[:pending]) }
      let(:paid_invoice_iugu) { ::Iugu::Subscription.new(@attributes={
        "id"=>"C963AAF1125D4AFCA1FCC83F494947FF", "due_date"=>"2017-10-10",
        "currency"=>"BRL", "discount_cents"=>nil, "email"=>"shughes@flipstorm.info",
        "notification_url"=>nil, "return_url"=>nil, "status"=>"paid", "tax_cents"=>nil,
        "updated_at"=>"2017-11-13T05:46:42-02:00", "total_cents"=>2222, "total_paid_cents"=>0,
        "paid_at"=>nil, "taxes_paid_cents"=>nil, "paid_cents"=>nil, "cc_emails"=>nil, "payable_with"=>"all",
        "overpaid_cents"=>nil, "ignore_due_email"=>true, "ignore_canceled_email"=>nil, "advance_fee_cents"=>nil,
        "commission_cents"=>nil, "early_payment_discount"=>false, "secure_id"=>"c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7",
        "secure_url"=>"https://faturas.iugu.com/c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7",
        "customer_id"=>"7A9E0083A898485F875590DFF4597549", "customer_ref"=>"Diana Medina",
        "customer_name"=>"Diana Medina", "user_id"=>nil, "total"=>"R$ 22,22", "taxes_paid"=>"R$ 0,00",
        "total_paid"=>"R$ 0,00", "total_overpaid"=>"R$ 0,00", "commission"=>"R$ 0,00", "fines_on_occurrence_day"=>nil,
        "total_on_occurrence_day"=>nil, "fines_on_occurrence_day_cents"=>nil, "total_on_occurrence_day_cents"=>nil,
        "financial_return_date"=>nil, "advance_fee"=>nil, "paid"=>"R$ 0,00", "interest"=>nil, "discount"=>nil,
        "created_at"=>"03/11, 15:26 h", "refundable"=>nil, "installments"=>nil, "transaction_number"=>1111, "payment_method"=>nil,
        "created_at_iso"=>"2017-11-03T15:26:07-02:00", "updated_at_iso"=>"2017-11-13T05:46:42-02:00", "occurrence_date"=>nil,
        "financial_return_dates"=>nil, "bank_slip"=>nil, "items"=>[{"id"=>"77081F811FE54952AE31966491760816",
        "description"=>"Teste 2", "price_cents"=>2222, "quantity"=>1, "created_at"=>"2017-11-03T15:26:07-02:00",
        "updated_at"=>"2017-11-03T15:26:07-02:00", "price"=>"R$ 22,22"}], "early_payment_discounts"=>[],
        "variables"=>[{"id"=>"8E0163AF92764E50B10FD5D5B1321004", "variable"=>"hl", "value"=>"pt-BR"},
          {"id"=>"5B85B8FB20F4462FBEF1E31B274A7C6E", "variable"=>"last_dunning_day", "value"=>"5"},
          {"id"=>"00C0A102A3D94BC8B98C940F3627A822", "variable"=>"payer.address.city", "value"=>"Porto Alegre"},
          {"id"=>"8EC87DB8238B4B7AB8CA1FB3737C7086", "variable"=>"payer.address.complement", "value"=>"Casa 2"},
          {"id"=>"EC7FECC0B27A4270B859B0A6CC12D03A", "variable"=>"payer.address.district", "value"=>"Farroupilha"},
          {"id"=>"954056171A834DE099DDB96E99F63D20", "variable"=>"payer.address.number", "value"=>"203"},
          {"id"=>"F12FA7DFE96143FAABFE690876DA3BE2", "variable"=>"payer.address.state", "value"=>"RS"},
          {"id"=>"B5D7FABF86A245768E66AE8ABFC1BC9B", "variable"=>"payer.address.street", "value"=>"Avenida Paulo Gama"},
          {"id"=>"D4CB638C2B2840BAAEA76B39D57A0977", "variable"=>"payer.address.zip_code", "value"=>"90040-060"},
          {"id"=>"92FBA7D38A7F4623A4AC344F966501FD", "variable"=>"payer.cpf_cnpj", "value"=>"011.354.780-31"},
          {"id"=>"E5D11B8E72DA4B25AA800AF074F686EA", "variable"=>"payer.name", "value"=>"Diana Medina"},
          {"id"=>"BD53D47C07F243D2B789B31B49882D6B", "variable"=>"payment_data.transaction_number", "value"=>"1111"}],
        "custom_variables"=>[], "logs"=>[{"id"=>"5D788A674E5041209371A855F8DF5CF1", "description"=>"Invoice viewed!",
          "notes"=>"Invoice viewed!", "created_at"=>"07/11, 10:50 h"}]})
      }
      before { Mconf::Iugu.stub(:fetch_invoice).and_return(paid_invoice_iugu) }
      subject { target.check_payment }

      it "should update the flag to paid" do
        target.flag_invoice_status.should eql(Invoice::INVOICE_STATUS[:pending])
        subject
        target.flag_invoice_status.should eql(Invoice::INVOICE_STATUS[:paid])
      end
    end
  end

  describe "#reference_this_month?" do
    let(:target) { FactoryGirl.create(:invoice) }
    before { Timecop.freeze(DateTime.now.utc) }
    after { Timecop.return }

    context "when it's due this month" do
      [DateTime.now.utc, DateTime.now.utc.beginning_of_month, DateTime.now.utc.end_of_month].each do |due|
        it("due_date: #{due}") {
          target.update_attributes(due_date: due+1.month)
          target.reference_this_month?.should be(true)
        }
      end
    end

    context "when it's not due this month" do
      [DateTime.now.utc - 1.month,
       DateTime.now.utc - 1.year,
       DateTime.now.utc - 1.year - 3.months,
       DateTime.now.utc + 1.month,
       DateTime.now.utc + 1.year,
       DateTime.now + 1.year + 2.months,
       DateTime.now.utc.beginning_of_month - 1.second,
       DateTime.now.utc.end_of_month + 1.second].each do |due|
        it("due_date: #{due}") {
          target.update_attributes(due_date: due+1.month)
          target.reference_this_month?.should be(false)
        }
      end
    end
  end

  describe "#reference_month" do
    let(:due_date) { Mconf::Timezone.parse_in_timezone('14/01/2017 16:00', 'Brasilia') }
    let(:invoice) { FactoryGirl.create(:invoice, due_date: due_date) }
    it { invoice.reference_month.should eql('2016-12') }
  end

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:report])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }

    context "an user on his own invoice page" do
      let(:user) { FactoryGirl.create(:user) }
      let(:subscription) { FactoryGirl.create(:subscription, user_id: user.id) }
      let(:target) { FactoryGirl.create(:invoice, subscription_id: subscription.id) }
      it { should_not be_able_to_do_anything_to(target).except([:index, :show, :report]) }
    end

    context "an user on another user's invoice" do
      let(:user) { FactoryGirl.create(:user) }
      let(:target) { FactoryGirl.create(:invoice) }
      it { should_not be_able_to_do_anything_to(target) }
    end

  end
end
