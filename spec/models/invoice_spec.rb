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

  describe "create" do
    context "Create an invoice for a subscription" do
      let(:subscription) { FactoryGirl.create(:subscription) }
      subject { subscription.invoices.create(due_date: DateTime.now.change({day: 10}), flag_invoice_status: "local") }
      it { expect { subject }.to change{ Invoice.count }.by(1) }
    end
  end

  describe "calculate how many days the user should be charged for" do
    before { DateTime.stub(:now).and_return(DateTime.civil(2017, 10, 10).beginning_of_day.utc) }

    context "#generate_consumed_days for new subscription" do
      let(:target) { FactoryGirl.create(:invoice, days_consumed: 0) }
      subject { target.generate_consumed_days("create") }

      it "should return 20 days because it started on the 10th of the month" do
        subject
        target.days_consumed.should eql(20)
      end
    end

    context "#generate_consumed_days for cancelled subscription" do
      let(:target) { FactoryGirl.create(:invoice, days_consumed: 0) }
      subject { target.generate_consumed_days("destroy") }

      it "should return 10 days because its being cancelled on the 10th of the month" do
        subject
        target.days_consumed.should eql(10)
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

  describe "invoice values generated" do
    skip "calculate the invoice value #generate_invoice_value"

    ########################################
    # test for 500 users                   #
    # self.update_attributes(user_qty: 500)#
    ########################################


    ########################################
    #test for 15 days usage:               #
    #self.days_consumed = 20               #
    #result[:discounts][:days] = 20.0/30.0 #
    ########################################
  end

  describe "post invoice to the ops #post_invoice_to_ops" do
    let(:subscription) { FactoryGirl.create(:subscription) }
    let(:invoice) { FactoryGirl.create(:invoice, subscription_id: subscription.id) }
    #generation of invoice value will be stubbed to return all scenarios for a regular user (non-integrator)
    context "post an invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{},
                                       :quantity=>30, :cost_per_user=>600, :total=>18000.0, :minimum=>false}) }
    end

    context "post an invoice with consumed days discount" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:days=>0.8},
                                       :quantity=>30, :cost_per_user=>600, :total=>14400.0, :minimum=>false}) }
    end

    context "post an invoice with user treshold discount" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3},
                                       :quantity=>1005, :cost_per_user=>600, :total=>422100.0, :minimum=>false}) }
    end

    context "post an invoice with user treshold and consumed days discount" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3, :days=>0.8},
                                       :quantity=>1005, :cost_per_user=>600, :total=>337680.0, :minimum=>false}) }
    end

    context "post a minimum fee invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{},
                                       :quantity=>5, :cost_per_user=>600, :total=>9000.0, :minimum=>true}) }
    end

    context "post a minimum fee with consumed days discount invoice" do
      before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:days=>0.8},
                                       :quantity=>5, :cost_per_user=>600, :total=>7200.0, :minimum=>true}) }
    end


  end

  describe "values generated for invoice#show are correct using arbitrary return" do
    let(:target) { FactoryGirl.create(:invoice) }

    before { Invoice.any_instance.stub(:generate_invoice_value).and_return({:discounts=>{:users=>0.3, :days=>0.7333333333333333},
                                       :quantity=>1000, :cost_per_user=>600, :total=>308000.0, :minimum=>false}) }

    context "#invoice_full_price" do
      it { target.invoice_full_price.should eql("+ R$ 6000.00")}
    end

    context "#invoice_users_discount" do
      it { target.invoice_users_discount.should eql("- R$ 1800.00")}
    end

    context "#invoice_days_discount" do
      it { target.invoice_days_discount.should eql("- R$ 1120.00")}
    end

    context "#invoice_total" do
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
      it { target.report_file_path.should eql("/vagrant/private/subscriptions/#{(target.due_date-1.month).strftime("%Y-%m")}/#{user.id}/#{Rails.application.config.report_en}") }
    end
    context "#csv_file_path" do
      it { target.csv_file_path.should eql("/vagrant/private/subscriptions/#{(target.due_date-1.month).strftime("%Y-%m")}/#{user.id}/unique-users.csv") }
    end
  end

  describe "get the invoices data (url and token)" do
    context "#get_invoice_payment_data" do
      let(:target) { FactoryGirl.create(:invoice, due_date: DateTime.civil(2017, 10, 10).utc, invoice_token: nil, invoice_url: nil) }
      let(:invoice_iugu) { ::Iugu::Subscription.new(@attributes={"id"=>"C963AAF1125D4AFCA1FCC83F494947FF", "due_date"=>"2017-10-10",
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
                                                                    "notes"=>"Invoice viewed!", "created_at"=>"07/11, 10:50 h"}]}) }

      before { Mconf::Iugu.stub(:fetch_user_invoices).and_return([invoice_iugu]) }
      subject { target.get_invoice_payment_data }

      it "should update the values to data from iugu ops" do
       target.invoice_url.should eql(nil)
       target.invoice_token.should eql(nil)
       subject
       target.invoice_url.should eql("https://faturas.iugu.com/c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7")
       target.invoice_token.should eql("C963AAF1125D4AFCA1FCC83F494947FF")
      end
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