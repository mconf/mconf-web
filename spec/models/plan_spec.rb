# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Plan do

  it { should validate_presence_of(:name)           }
  it { should validate_presence_of(:identifier)     }
  it { should validate_presence_of(:ops_type)       }
  it { should validate_presence_of(:currency)       }
  it { should validate_presence_of(:interval)       }
  it { should validate_presence_of(:interval_type)  }

  before { Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number) }
  before { Mconf::Iugu.stub(:destroy_plan).and_return(true) }

  describe "#create_ops_plan" do
    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:plan, ops_token: nil) }
      before { Mconf::Iugu.stub(:create_plan).and_return(nil) }
      subject { Plan.create(attrs) }
      it { subject.new_record?.should be(true) }
      it { subject.errors.should have_key(:ops_error) }
      it { expect { subject }.to change{ Plan.count }.by(0) }
    end

    context "OPS returns a token" do
      # Stubed to return a token, so we give a nil token as attr but receive one
      let(:attrs) { FactoryGirl.attributes_for(:plan, ops_token: nil) }
      subject { Plan.create(attrs) }
      it { expect { subject }.to change{ Plan.count }.by(1) }
    end
  end

  describe "#import_ops_plan" do
    before { FactoryGirl.create(:plan, ops_token: "ABC123456") }
    let(:present_plan) { ::Iugu::Plan.new(@attributes={"id"=>"ABC123456",
                                           "name"=>"Basic Plan", "identifier"=>"base", "interval"=>1,
                                           "interval_type"=>"months", "created_at"=>"2017-09-27T17:33:03-03:00",
                                           "updated_at"=>"2017-09-27T17:33:03-03:00",
                                           "prices"=>[{"created_at"=>"2017-09-27T17:33:03-03:00",
                                           "currency"=>"BRL", "id"=>"ABC123456789101112",
                                           "updated_at"=>"2017-09-27T17:33:03-03:00", "value_cents"=>0}],
                                           "features"=>[], "payable_with"=>"all"}) }

    let(:importable_plan) { ::Iugu::Plan.new(@attributes={"id"=>"654321CBA",
                                           "name"=>"Not so Basic Plan", "identifier"=>"basesome", "interval"=>1,
                                           "interval_type"=>"months", "created_at"=>"2017-09-27T17:33:03-03:00",
                                           "updated_at"=>"2017-09-27T17:33:03-03:00",
                                           "prices"=>[{"created_at"=>"2017-09-27T17:33:03-03:00",
                                           "currency"=>"BRL", "id"=>"121110987654321CBA",
                                           "updated_at"=>"2017-09-27T17:33:03-03:00", "value_cents"=>0}],
                                           "features"=>[], "payable_with"=>"all"}) }

    context "the plan already exists in our database" do
      before { Mconf::Iugu.stub(:fetch_all_plans).and_return([present_plan]) }
      subject { Plan.import_ops_plan }
      it { expect { subject }.to change{ Plan.count }.by(0) }
    end

    context "the plan is imported correctly" do
      before { Mconf::Iugu.stub(:fetch_all_plans).and_return([importable_plan]) }
      subject { Plan.import_ops_plan }
      it { expect { subject }.to change{ Plan.count }.by(1) }
    end

    context "there are no plans to import from ops" do
      before { Mconf::Iugu.stub(:fetch_all_plans).and_return(nil) }
      subject { Plan.import_ops_plan }
      it { expect { subject }.to change{ Plan.count }.by(0) }
    end
  end

  describe "#delete_ops_plan" do
    context "delete failed by OPS" do
      before { Mconf::Iugu.stub(:destroy_plan).and_return(false) }
      let!(:indestructible_plan) { FactoryGirl.create(:plan, ops_token: "NK3320") }
      subject { indestructible_plan.destroy }
      it { expect { subject }.to change{ Plan.count }.by(0) }
    end

    context "delete confirmed by OPS" do
      let!(:destructible_plan) { FactoryGirl.create(:plan, ops_token: "2138127302173AB") }
      subject { destructible_plan.destroy }
      it { expect { subject }.to change{ Plan.count }.by(-1) }
    end
  end
end