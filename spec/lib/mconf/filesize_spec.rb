# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Filesize do
  let(:target) { Mconf::Filesize }

  describe '#human_file_size' do
    context 'without arguments' do
      it { target.human_file_size.should be_nil }
    end

    context 'with empty values' do
      it { target.human_file_size("").should be_nil }
      it { target.human_file_size(" \t  ").should be_nil }
    end

    context 'adjusts the unit returned' do
      it { target.human_file_size(0).should eq("0.00 B") }
      it { target.human_file_size(1000).should eq("1.00 kB") }
      it { target.human_file_size(1000000).should eq("1.00 MB") }
      it { target.human_file_size(1000000000).should eq("1.00 GB") }
    end

    context 'works if the input is a string' do
      it { target.human_file_size("0").should eq("0.00 B") }
      it { target.human_file_size("1000").should eq("1.00 kB") }
      it { target.human_file_size("1000000").should eq("1.00 MB") }
      it { target.human_file_size("1000000000").should eq("1.00 GB") }
    end
  end

  context "#convert" do
    it("works") { target.convert("15000000").should eql(15000000) }
    it("works with integers") { target.convert(15000000).should eql(15000000) }
    it("converts GB properly") { target.convert("15 GB").should eql(15000000000) }
    it("converts G properly") { target.convert("15 G").should eql(15000000000) }
    it("converts GiB properly") { target.convert("15 GiB").should eql(16106127360) }
    it("converts MB properly") { target.convert("15 MB").should eql(15000000) }
    it("converts M properly") { target.convert("15 M").should eql(15000000) }
    it("converts MiB properly") { target.convert("15 MiB").should eql(15728640) }
    it("converts kB properly") { target.convert("15 kB").should eql(15000) }
    it("converts k properly") { target.convert("15 k").should eql(15000) }
    it("converts kiB properly") { target.convert("15 kiB").should eql(15360) }
    it("returns nil for empty strings") { target.convert("").should be_nil }
    it("returns nil for strings with only blank characters") { target.convert("  \t ").should be_nil }
    it("returns nil for nil values") { target.convert(nil).should be_nil}
    it("returns nil for invalid numbers") { target.convert(-5).should be_nil }
    it("returns nil for invalid") { target.convert("daileon").should be_nil }
  end

  describe '#is_number?' do
    it("an int") { target.is_number?(1).should be(true) }
    it("a float") { target.is_number?(1.2).should be(true) }
    it("an object") { target.is_number?(Object.new).should be(false) }
    it("an array") { target.is_number?([2]).should be(false) }
    it("a hash") { target.is_number?({ a: 2 }).should be(false) }

    context "a string with" do
      it("an int") { target.is_number?("1").should be(true) }
      it("a float") { target.is_number?("1.2").should be(true) }
      it("a text") { target.is_number?("teste").should be(false) }
      it("empty") { target.is_number?("").should be(false) }
    end
  end

  describe '#is_filesize?' do
    it { target.is_filesize?("10").should be(true) }
    it { target.is_filesize?("10 B").should be(true) }
    it { target.is_filesize?("10 kB").should be(true) }
    it { target.is_filesize?("10 KiB").should be(true) }
    it { target.is_filesize?("10 M").should be(true) }
    it { target.is_filesize?("10 MB").should be(true) }
    it { target.is_filesize?("10 MiB").should be(true) }
    it { target.is_filesize?("10 G").should be(true) }
    it { target.is_filesize?("10 GB").should be(true) }
    it { target.is_filesize?("10 GiB").should be(true) }
    it { target.is_filesize?("10 T").should be(true) }
    it { target.is_filesize?("10 TB").should be(true) }
    it { target.is_filesize?("10 TiB").should be(true) }
    it { target.is_filesize?("hi").should be(false) }
    it { target.is_filesize?(10).should be(false) }
    it { target.is_filesize?(10.5).should be(false) }
    it { target.is_filesize?([1, 2]).should be(false) }
    it { target.is_filesize?({ a: 1}).should be(false) }
  end

end
