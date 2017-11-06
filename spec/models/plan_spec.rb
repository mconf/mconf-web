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

  describe "#create_ops_plan" do
    context "no token returned from OPS" do
      let(:attrs) { FactoryGirl.attributes_for(:plan, ops_token: nil) }
      # before { Mconf::Iugu.stub(:create_customer).and_return(nil) }
      # subject { Subscription.create(attrs) }
      # it { subject.new_record?.should be(true) }
      # it { subject.errors.should have_key(:ops_error) }
    end
  end
  skip "test importing of a plan from iugu"
  skip "get the plans and associate to a created subscription"
  skip "remove the plans in command line"
end