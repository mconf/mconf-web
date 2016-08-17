# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Site do

  describe "before validation" do
    context "formats #max_upload_size" do
      # note: needs a random value set in max_upload_size, different from all tests
      let(:target) { FactoryGirl.create(:site, max_upload_size: "9999999999") }

      it("works") {
        target.max_upload_size = "15000000"
        target.save
        target.reload.max_upload_size.should eql("15000000")
      }
      it("works with integers") {
        target.max_upload_size = 15000000
        target.save
        target.reload.max_upload_size.should eql("15000000")
      }
      it("converts GB properly") {
        target.max_upload_size = "15 GB"
        target.save
        target.reload.max_upload_size.should eql("15000000000")
      }
      it("converts G properly") {
        target.max_upload_size = "15 G"
        target.save
        target.reload.max_upload_size.should eql("15000000000")
      }
      it("converts GiB properly") {
        target.max_upload_size = "15 GiB"
        target.save
        target.reload.max_upload_size.should eql("16106127360")
      }
      it("converts MB properly") {
        target.max_upload_size = "15 MB"
        target.save
        target.reload.max_upload_size.should eql("15000000")
      }
      it("converts M properly") {
        target.max_upload_size = "15 M"
        target.save
        target.reload.max_upload_size.should eql("15000000")
      }
      it("converts MiB properly") {
        target.max_upload_size = "15 MiB"
        target.save
        target.reload.max_upload_size.should eql("15728640")
      }
      it("converts kB properly") {
        target.max_upload_size = "15 kB"
        target.save
        target.reload.max_upload_size.should eql("15000")
      }
      it("converts k properly") {
        target.max_upload_size = "15 k"
        target.save
        target.reload.max_upload_size.should eql("15000")
      }
      it("converts kiB properly") {
        target.max_upload_size = "15 kiB"
        target.save
        target.reload.max_upload_size.should eql("15360")
      }
      it("sets empty strings as nil") {
        target.max_upload_size = ""
        target.save
        target.reload.max_upload_size.should be_nil
      }
      it("sets strings with only blank characters as nil") {
        target.max_upload_size = "  \t "
        target.save
        target.reload.max_upload_size.should be_nil
      }
      it("sets nil as nil") {
        target.max_upload_size = nil
        target.save
        target.reload.max_upload_size.should be_nil
      }
      it("sets 0 as 0") {
        target.max_upload_size = 0
        target.save
        target.reload.max_upload_size.should eql("0")
      }
    end
  end

  describe "#formatted_max_upload_size" do
    let(:target) { FactoryGirl.create(:site) }

    it {
      target.max_upload_size = "15000000"
      target.formatted_max_upload_size.should eql("15.00 MB")
    }
    it {
      target.max_upload_size = "15666000"
      target.formatted_max_upload_size.should eql("15.67 MB")
    }
    it {
      target.max_upload_size = "15000"
      target.formatted_max_upload_size.should eql("15.00 kB")
    }
  end
end
