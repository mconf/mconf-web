# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf do

  describe '#generate_dial_number' do
    before {
      Site.current.update_attributes(room_dial_number_pattern: pattern)
      # Random values are stubbed
      allow(Kernel).to receive(:rand).and_return(3, 2, 3, 1, 4)
    }

    context 'with no pattern configured for the site' do
      let(:pattern) { nil }
      it { Mconf::generate_dial_number.should be_nil }
    end

    context 'pattern "6xxx"' do
      let(:pattern) { '6xxx' }

      it { Mconf::generate_dial_number.should eq('6323') }
    end

    context 'pattern "99x-x0x"' do
      let(:pattern) { '99x-x0x' }

      it { Mconf::generate_dial_number.should eq('993-203') }
    end

    context 'pattern "000-xAAA" and custom symbol "A"' do
      let(:pattern) { '0AA-xAAA' }

      it { Mconf::generate_dial_number(symbol: 'A').should eq('032-x314') }
    end

    context 'pattern "6xxx-xx" passed via parameter' do
      let(:pattern) { 'dont-matter' }

      it { Mconf::generate_dial_number(pattern: '6xxx-xx').should eq('6323-14') }
    end

    context 'pattern "5aa-aa" and custom symbol "a" passed via parameters' do
      let(:pattern) { 'dont-matter' }

      it { Mconf::generate_dial_number(pattern: '5aa-aa', symbol: 'a').should eq('532-31') }
    end
  end

end
