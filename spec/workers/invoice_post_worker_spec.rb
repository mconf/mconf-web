# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvoicePostWorker, type: :worker do
  let(:worker) { InvoicePostWorker }
  let!(:invoice) { FactoryGirl.create(:invoice, flag_invoice_status: "local") }
  before {  Mconf::Iugu.stub(:add_invoice_item).and_return(true) }
  subject { worker.perform(invoice.id) }

  describe "#perform" do

    context "invoice.flag_invoice_status == 'local'" do
      # FYI: posted = self.check_for_posted_invoices
      context "posted.first.present" do
        before { Mconf::Iugu.stub(:get_invoice_items).and_return([{"id"=>"EF62061C3FEE499782858DF5272C309D",
                                                              "description"=>"Minimum service fee",
                                                              "quantity"=>15,
                                                              "price_cents"=>600,
                                                              "recurrent"=>false,
                                                              "price"=>"R$ 6,00",
                                                              "total"=>"R$ 90,00"}]) }
        it "changes to posted" do
          subject
          invoice.reload
          invoice.flag_invoice_status.should eql("posted")
        end
      end

      context "!posted.first.present" do
        before { Mconf::Iugu.stub(:get_invoice_items).and_return([]) }
        it "does not change to posted" do
          subject
          invoice.flag_invoice_status.should eql("local")
        end
      end
    end
  end
end
