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


  skip "get the invoices data (url and token)"
  skip "calculate the invoice value"
  skip "test posting the invoice value"
  skip "test getting the related files"

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