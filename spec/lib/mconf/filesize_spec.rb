# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Filesize do

  describe '#human_file_size' do
    context 'without arguments' do
      it { Mconf::Filesize.human_file_size.should eq("0.00 B") }
    end

    context 'adjusts the unit returned' do
      it { Mconf::Filesize.human_file_size(1000).should eq("1.00 kB") }
      it { Mconf::Filesize.human_file_size(1000000).should eq("1.00 MB") }
      it { Mconf::Filesize.human_file_size(1000000000).should eq("1.00 GB") }
    end

    context 'works if the input is a string' do
      it { Mconf::Filesize.human_file_size("1000").should eq("1.00 kB") }
      it { Mconf::Filesize.human_file_size("1000000").should eq("1.00 MB") }
      it { Mconf::Filesize.human_file_size("1000000000").should eq("1.00 GB") }
    end
  end

  describe '#is_number?' do
    it("an int") { Mconf::Filesize.is_number?(1).should be(true) }
    it("a float") { Mconf::Filesize.is_number?(1.2).should be(true) }
    it("an object") { Mconf::Filesize.is_number?(Object.new).should be(false) }
    it("an array") { Mconf::Filesize.is_number?([2]).should be(false) }
    it("a hash") { Mconf::Filesize.is_number?({ a: 2 }).should be(false) }

    context "a string with" do
      it("an int") { Mconf::Filesize.is_number?("1").should be(true) }
      it("a float") { Mconf::Filesize.is_number?("1.2").should be(true) }
      it("a text") { Mconf::Filesize.is_number?("teste").should be(false) }
      it("empty") { Mconf::Filesize.is_number?("").should be(false) }
    end
  end

  describe '#is_filesize?' do
    it { Mconf::Filesize.is_filesize?("10").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 B").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 kB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 KiB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 M").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 MB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 MiB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 G").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 GB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 GiB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 T").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 TB").should be(true) }
    it { Mconf::Filesize.is_filesize?("10 TiB").should be(true) }
    it { Mconf::Filesize.is_filesize?("hi").should be(false) }
    it { Mconf::Filesize.is_filesize?(10).should be(false) }
    it { Mconf::Filesize.is_filesize?(10.5).should be(false) }
    it { Mconf::Filesize.is_filesize?([1, 2]).should be(false) }
    it { Mconf::Filesize.is_filesize?({ a: 1}).should be(false) }
  end

end
