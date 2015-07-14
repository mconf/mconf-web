# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf do

  describe '#generate_dial_number' do
    context 'with no arguments informed' do
      it { Mconf::DialNumber.generate.should be_nil }
    end

    context 'pattern "6xxx-xx"' do
      it { Mconf::DialNumber.generate('6xxx-xx').should eq('6000-00') }
    end

    context 'pattern "0AA-xAAA" and custom symbol "A"' do
      it { Mconf::DialNumber.generate('0AA-xAAA', symbol: 'A').should eq('000-x000') }
    end

    context 'pattern "5aa-aa" and custom symbol "a" and current_room_dial_number_pattern being set' do
      before { Site.current.update_attributes(current_room_dial_number_pattern: 1234) }

      it { Mconf::DialNumber.generate('5aa-aa', symbol: 'a').should eq('512-34') }
    end

    context 'pattern changes after having been used to set some numbers' do
      let(:pattern) { '67xxx-xxx' }
      before do
        Site.current.update_attributes(room_dial_number_pattern: pattern)
        Site.current.update_attributes(current_room_dial_number_pattern: 32001)
        expect(Mconf::DialNumber.generate(pattern)).to eq('67032-001')
        expect(Mconf::DialNumber.generate(pattern)).to eq('67032-002')
        expect(Mconf::DialNumber.generate(pattern)).to eq('67032-003')
      end

      it { Mconf::DialNumber.generate(pattern).should eq('67032-004') }
      it { Site.current.current_room_dial_number_pattern.should eq(32004) }
    end

    context 'returns nil if there are no more dial numbers' do
      let(:pattern) { '22xx' }

      it { Mconf::DialNumber.generate(pattern, current: 100).should eq(nil) }
    end
  end

  describe '#get_dial_number_from_ordinal' do
    let(:pattern) { '98xxxx-xxx'}
    let(:n1) { 34 }
    let(:n2) { 142 }
    let(:n3) { 2112 }

    it { Mconf::DialNumber.get_dial_number_from_ordinal(n1, pattern).should eq('980000-034') }
    it { Mconf::DialNumber.get_dial_number_from_ordinal(n2, pattern).should eq('980000-142') }
    it { Mconf::DialNumber.get_dial_number_from_ordinal(n3, pattern).should eq('980002-112') }

    context 'with pattern as nil' do
      it { Mconf::DialNumber.get_dial_number_from_ordinal(n1, nil).should eq(nil) }
      it { Mconf::DialNumber.get_dial_number_from_ordinal(n2, nil).should eq(nil) }
      it { Mconf::DialNumber.get_dial_number_from_ordinal(n3, nil).should eq(nil) }
    end
  end

  describe '#get_ordinal_from_dial_number' do
    let(:pattern) { '67xxx-xxx'}
    let(:n1) { '67000-001' }
    let(:n2) { '67001-001' }
    let(:n3) { '67123-321' }

    it { Mconf::DialNumber.get_ordinal_from_dial_number(n1, pattern).should eq(1) }
    it { Mconf::DialNumber.get_ordinal_from_dial_number(n2, pattern).should eq(1001) }
    it { Mconf::DialNumber.get_ordinal_from_dial_number(n3, pattern).should eq(123321) }

    context 'with pattern as nil' do
      let(:pattern) { nil }

      it { Mconf::DialNumber.get_ordinal_from_dial_number(n1, pattern).should eq(nil) }
      it { Mconf::DialNumber.get_ordinal_from_dial_number(n2, pattern).should eq(nil) }
      it { Mconf::DialNumber.get_ordinal_from_dial_number(n3, pattern).should eq(nil) }
    end

    context 'with a pattern that doesnt match the number' do
      let(:pattern) { '88xxx-xxx' }

      it { Mconf::DialNumber.get_ordinal_from_dial_number(n1, pattern).should eq(nil) }
      it { Mconf::DialNumber.get_ordinal_from_dial_number(n2, pattern).should eq(nil) }
      it { Mconf::DialNumber.get_ordinal_from_dial_number(n3, pattern).should eq(nil) }
    end

  end

end
