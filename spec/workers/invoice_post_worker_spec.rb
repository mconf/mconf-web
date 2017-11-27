# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvoicePostWorker, type: :worker do
  let(:worker) { InvoicePostWorker }
  let(:invoice) { FactoryGirl.create(:invoice, flag_invoice_status: "local") }
  before { Mconf::Iugu.stub(:add_invoice_item).and_return(true) }
  subject { worker.perform(invoice.id) }

  describe "#perform" do

    context "invoices_post" do
      context "invoice.flag_invoice_status == 'local'" do
        # FYI: posted = self.check_for_posted_invoices
        context "posted.first.present" do
          before {
            Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(15)
            Mconf::Iugu.stub(:get_invoice_items).and_return(
              [
                { "id"=>"EF62061C3FEE499782858DF5272C309D",
                  "description"=>"Minimum service fee",
                  "quantity"=>15,
                  "price_cents"=>600,
                  "recurrent"=>false,
                  "price"=>"R$ 6,00",
                  "total"=>"R$ 90,00"
                }
              ]
            )
          }
          it "changes to posted" do
            subject
            invoice.reload
            invoice.flag_invoice_status.should eql("posted")
          end
        end

        context "!posted.first.present" do
          before {
            Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(1)
            Mconf::Iugu.stub(:get_invoice_items).and_return([])
          }
          it "does not change to posted" do
            subject
            invoice.flag_invoice_status.should eql("local")
          end
        end
      end
    end

    context "invoices_sync" do
      let(:subscription) { FactoryGirl.create(:subscription, customer_token: "7A9E0083A898485F875590DFF4597549") }

      context "unless invoice_url.present? || invoice.flag_invoice_status != 'posted'" do
        let!(:invoice) { FactoryGirl.create(:invoice, id: 10, flag_invoice_status: "posted", invoice_url: nil, invoice_token: nil, due_date: (DateTime.now.change({day: 10}))) }
        let!(:iugu_invoice) { ::Iugu::Invoice.new(@attributes={"id"=>"C963AAF1125D4AFCA1FCC83F494947FF",
                                                        "due_date"=>"2017-11-08",
                                                        "currency"=>"BRL",
                                                        "discount_cents"=>nil,
                                                        "email"=>"shughes@flipstorm.info",
                                                        "notification_url"=>nil,
                                                        "return_url"=>nil,
                                                        "status"=>"pending",
                                                        "tax_cents"=>nil,
                                                        "updated_at"=>"2017-11-03T15:26:07-02:00",
                                                        "total_cents"=>2222,
                                                        "total_paid_cents"=>0,
                                                        "paid_at"=>nil,
                                                        "taxes_paid_cents"=>nil,
                                                        "paid_cents"=>nil,
                                                        "cc_emails"=>nil,
                                                        "payable_with"=>"all",
                                                        "overpaid_cents"=>nil,
                                                        "ignore_due_email"=>true,
                                                        "ignore_canceled_email"=>nil,
                                                        "advance_fee_cents"=>nil,
                                                        "commission_cents"=>nil,
                                                        "early_payment_discount"=>false,
                                                        "secure_id"=>"c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7",
                                                        "secure_url"=>"https://faturas.iugu.com/c963aaf1-125d-4afc-a1fc-c83f494947ff-84e7",
                                                        "customer_id"=>"7A9E0083A898485F875590DFF4597549",
                                                        "customer_ref"=>"Diana Medina",
                                                        "customer_name"=>"Diana Medina",
                                                        "user_id"=>nil, "total"=>"R$ 22,22",
                                                        "taxes_paid"=>"R$ 0,00",
                                                        "total_paid"=>"R$ 0,00",
                                                        "total_overpaid"=>"R$ 0,00",
                                                        "commission"=>"R$ 0,00",
                                                        "fines_on_occurrence_day"=>nil,
                                                        "total_on_occurrence_day"=>nil,
                                                        "fines_on_occurrence_day_cents"=>nil,
                                                        "total_on_occurrence_day_cents"=>nil,
                                                        "financial_return_date"=>nil,
                                                        "advance_fee"=>nil,
                                                        "paid"=>"R$ 0,00",
                                                        "interest"=>nil,
                                                        "discount"=>nil,
                                                        "created_at"=>"03/11, 15:26 h",
                                                        "refundable"=>nil,
                                                        "installments"=>nil,
                                                        "transaction_number"=>1111,
                                                        "payment_method"=>nil,
                                                        "created_at_iso"=>"2017-11-03T15:26:07-02:00",
                                                        "updated_at_iso"=>"2017-11-03T15:26:07-02:00",
                                                        "occurrence_date"=>nil,
                                                        "financial_return_dates"=>nil,
                                                        "bank_slip"=>nil,
                                                        "items"=>[{"id"=>"77081F811FE54952AE31966491760816",
                                                                  "description"=>"Teste 2",
                                                                  "price_cents"=>2222,
                                                                  "quantity"=>1,
                                                                  "created_at"=>"2017-11-03T15:26:07-02:00",
                                                                  "updated_at"=>"2017-11-03T15:26:07-02:00",
                                                                  "price"=>"R$ 22,22"}],
                                                        "early_payment_discounts"=>[],
                                                        "variables"=>[{"id"=>"8E0163AF92764E50B10FD5D5B1321004",
                                                                       "variable"=>"hl",
                                                                       "value"=>"pt-BR"},
                                                                      {"id"=>"00C0A102A3D94BC8B98C940F3627A822",
                                                                       "variable"=>"payer.address.city",
                                                                       "value"=>"Porto Alegre"},
                                                                      {"id"=>"8EC87DB8238B4B7AB8CA1FB3737C7086",
                                                                       "variable"=>"payer.address.complement",
                                                                       "value"=>"Casa 2"},
                                                                      {"id"=>"EC7FECC0B27A4270B859B0A6CC12D03A",
                                                                       "variable"=>"payer.address.district",
                                                                       "value"=>"Farroupilha"},
                                                                      {"id"=>"954056171A834DE099DDB96E99F63D20",
                                                                       "variable"=>"payer.address.number",
                                                                       "value"=>"203"},
                                                                      {"id"=>"F12FA7DFE96143FAABFE690876DA3BE2",
                                                                       "variable"=>"payer.address.state",
                                                                       "value"=>"RS"},
                                                                      {"id"=>"B5D7FABF86A245768E66AE8ABFC1BC9B",
                                                                       "variable"=>"payer.address.street",
                                                                       "value"=>"Avenida Paulo Gama"},
                                                                      {"id"=>"D4CB638C2B2840BAAEA76B39D57A0977",
                                                                       "variable"=>"payer.address.zip_code",
                                                                       "value"=>"90040-060"},
                                                                      {"id"=>"92FBA7D38A7F4623A4AC344F966501FD",
                                                                       "variable"=>"payer.cpf_cnpj",
                                                                       "value"=>"011.354.780-31"},
                                                                      {"id"=>"E5D11B8E72DA4B25AA800AF074F686EA",
                                                                       "variable"=>"payer.name",
                                                                       "value"=>"Diana Medina"},
                                                                      {"id"=>"BD53D47C07F243D2B789B31B49882D6B",
                                                                       "variable"=>"payment_data.transaction_number",
                                                                       "value"=>"1111"}],
                                                        "custom_variables"=>[],
                                                        "logs"=>[]}) }
        before {
          Mconf::Iugu.stub(:fetch_user_invoices).and_return([iugu_invoice])
        }

        it "invoice.get_invoice_payment_data" do
          subject
          invoice.reload
          invoice.invoice_token.should eql(iugu_invoice.id)
          invoice.invoice_url.should eql(iugu_invoice.secure_url)
        end
      end
    end
  end
end
