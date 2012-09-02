# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Space do

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:space).should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it {
    FactoryGirl.create(:space)
    should validate_uniqueness_of(:name)
  }

end
