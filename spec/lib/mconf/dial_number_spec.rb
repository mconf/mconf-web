# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf do

  describe '#generate_dial_number' do
    before {
      # Random values are stubbed
      allow(Kernel).to receive(:rand).and_return(1, 2, 3, 4, 5, 6, 7, 8, 9, 0)
    }

    context 'with no arguments informed' do
      it { Mconf::DialNumber.generate.should be_nil }
    end

    context 'pattern "6xxx-xx"' do
      it { Mconf::DialNumber.generate('6xxx-xx').should eq('6123-45') }
    end

    context 'pattern "0AA-xAAA" and custom symbol "A"' do
      it { Mconf::DialNumber.generate('0AA-xAAA', symbol: 'A').should eq('012-x345') }
    end

    context 'pattern "5aa-aa" and custom symbol "a"' do
      it { Mconf::DialNumber.generate('5aa-aa', symbol: 'a').should eq('512-34') }
    end
  end

end
