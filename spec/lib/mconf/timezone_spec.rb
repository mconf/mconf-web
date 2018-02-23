# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Timezone do

  describe '#parse_in_timezone' do
    # custom format to use in the tests
    before {
      @previous_format = Time::DATE_FORMATS[:default]
      Time::DATE_FORMATS[:default] = '%d/%m/%Y %H:%M'
    }
    after {
      Time::DATE_FORMATS[:default] = @previous_format
    }

    context 'normal timezone (UTC)' do
      subject { Mconf::Timezone.parse_in_timezone('31/07/2015 16:00', 'UTC') }

      it { subject.hour.should eq(16) }
      it { subject.day.should eq(31) }
      it { subject.time_zone.name.should eq('UTC') }
    end

    context 'normal timezone (Brasilia)' do
      subject { Mconf::Timezone.parse_in_timezone('31/07/2015 16:00', 'Brasilia') }

      it { subject.hour.should eq(16) }
      it { subject.day.should eq(31) }
      it { subject.time_zone.name.should eq('Brasilia') }
      it { subject.utc.hour.should eq(19) }
    end

    context 'normal timezone (Newfoundland)' do
      subject { Mconf::Timezone.parse_in_timezone('31/07/2015 10:00', 'Newfoundland') }

      it { subject.hour.should eq(10) }
      it { subject.day.should eq(31) }
      it { subject.min.should eq(00) }

      it { subject.time_zone.name.should eq('Newfoundland') }

      it { subject.utc.hour.should eq(12) }
      it { subject.utc.min.should eq(30) }
    end

    context 'normal timezone changing the day (Brasilia)' do
      subject { Mconf::Timezone.parse_in_timezone('31/07/2015 21:00', 'Brasilia') }

      it { subject.hour.should eq(21) }
      it { subject.day.should eq(31) }
      it { subject.month.should eq(7) }
      it { subject.time_zone.name.should eq('Brasilia') }

      it { subject.utc.hour.should eq(0) }
      it { subject.utc.day.should eq(1) }
      it { subject.utc.month.should eq(8) }
    end

    context 'normal timezone compared with other timezone (US/Canada to Brasil)' do
      subject { Mconf::Timezone.parse_in_timezone('31/07/2015 14:23', 'Eastern Time (US & Canada)') }

      it { subject.hour.should eq(14) }
      it { subject.min.should eq(23) }
      it { subject.time_zone.name.should eq('Eastern Time (US & Canada)') }

      it { subject.in_time_zone('Brasilia').utc.should eq(Mconf::Timezone.parse_in_timezone('31/07/2015 15:23', 'Brasilia').utc) }
    end

    context 'daylight saving time cases (Brasilia)' do
      let(:date_no_dst) { Mconf::Timezone.parse_in_timezone('17/10/2015 23:00', 'Brasilia') }
      let(:date_dst) { Mconf::Timezone.parse_in_timezone('18/10/2015 23:00', 'Brasilia') }

      # test if date in it's own timezone is what we wanted
      it { date_no_dst.hour.should eq(23) }
      it { date_no_dst.day.should eq(17) }
      it { date_no_dst.month.should eq(10) }
      it { date_no_dst.time_zone.name.should eq('Brasilia') }

      # test if dates in different DST are still equal (or at least equivalent)
      it { date_no_dst.hour.should eq(date_dst.hour) }
      it { date_no_dst.day.should eq(date_dst.day - 1) }

      # Test without dst
      it { date_no_dst.utc.hour.should eq(2) }
      it { date_no_dst.utc.day.should eq(18) }

      # Test with dst
      it { date_dst.utc.hour.should eq(1) }
      it { date_dst.utc.day.should eq(19) }
    end

    context 'daylight saving time cases (Eastern Time (US & Canada))' do
      let(:date_dst) { Mconf::Timezone.parse_in_timezone('31/10/2015 23:00', 'Eastern Time (US & Canada)') }
      let(:date_no_dst) { Mconf::Timezone.parse_in_timezone('01/11/2015 23:00', 'Eastern Time (US & Canada)') }

      it { date_dst.hour.should eq(23) }
      it { date_dst.day.should eq(31) }
      it { date_dst.month.should eq(10) }
      it { date_dst.time_zone.name.should eq('Eastern Time (US & Canada)') }

      it { date_dst.hour.should eq(date_no_dst.hour) }
      it { date_dst.day.should eq(31) }

      it { date_dst.utc.hour.should eq(3) }
      it { date_dst.utc.day.should eq(1) }
      it { date_dst.utc.month.should eq(11) }

      it { date_no_dst.utc.hour.should eq(4) }
      it { date_no_dst.utc.day.should eq(2) }
      it { date_dst.utc.month.should eq(11) }
    end

    context 'compare Pacific Time with Eastern Time with DST in effect' do
      let(:pacific) { Mconf::Timezone.parse_in_timezone('01/07/2015 23:50', 'Pacific Time (US & Canada)') } # during DST it's -7h
      let(:eastern) { Mconf::Timezone.parse_in_timezone('02/07/2015 2:50', 'Eastern Time (US & Canada)') } # during DST it's -4h

      it { pacific.utc.hour.should eq(6) }
      it { pacific.utc.min.should eq(50) }
      it { pacific.utc.day.should eq(2) }

      it { pacific.utc.should eq(eastern.utc) }
    end

    context 'compare Pacific Time with Eastern Time with DST not in effect' do
      let(:pacific) { Mconf::Timezone.parse_in_timezone('02/11/2015 23:50', 'Pacific Time (US & Canada)') } # -8h
      let(:eastern) { Mconf::Timezone.parse_in_timezone('03/11/2015 2:50', 'Eastern Time (US & Canada)') } # -5h

      it { pacific.utc.hour.should eq(7) }
      it { pacific.utc.min.should eq(50) }
      it { pacific.utc.day.should eq(3) }

      it { pacific.utc.should eq(eastern.utc) }
    end

    context 'compare Pacific Time with Brasilia (different DST in effect)' do
      let(:brasilia) { Mconf::Timezone.parse_in_timezone('18/10/2015 23:00', 'Brasilia') } # Brasil's timezone is in DST (-2h)
      let(:eastern) { Mconf::Timezone.parse_in_timezone('18/10/2015 21:00', 'Eastern Time (US & Canada)') } # US/Canada is in DST too (-4h)

      it { brasilia.utc.hour.should eq(1) }
      it { brasilia.utc.min.should eq(0) }
      it { brasilia.utc.day.should eq(19) }

      it { brasilia.utc.should eq(eastern.utc) }
    end

    context 'compare Pacific Time with Brasilia (different DST in effect)' do
      let(:brasilia) { Mconf::Timezone.parse_in_timezone('17/10/2015 23:00', 'Brasilia') } # Brasil's timezone is not in DST (-3h)
      let(:eastern) { Mconf::Timezone.parse_in_timezone('17/10/2015 21:00', 'Eastern Time (US & Canada)') } # US/Canada is in DST (-4h)

      it { brasilia.utc.hour.should eq(2) }
      it { brasilia.utc.min.should eq(0) }
      it { brasilia.utc.day.should eq(18) }

      it { brasilia.utc.should_not eq(eastern.utc) }
      it { brasilia.utc.hour.should eq(eastern.utc.hour + 1) }
    end

  end

end

describe Mconf::DSTTimezone do
  describe "#new" do
    let(:tz) { ActiveSupport::TimeZone.all.first }

    context "receiving a timezone" do
      subject { Mconf::DSTTimezone.new(tz) }
      it{ subject.name.should eq(tz.name) }
      it{ subject.tzinfo.should eq(tz.tzinfo) }
    end

    context "receiving a string" do
      subject { Mconf::DSTTimezone.new(tz.name) }
      it{ subject.name.should eq(tz.name) }
      it{ subject.tzinfo.should eq(tz.tzinfo) }
    end
  end

  describe "#all" do
    subject { Mconf::DSTTimezone.all }
    it { subject.should_not be_empty }
  end

  describe "#dst_string" do

    context "in August" do
      let(:date) { DateTime.strptime('05/08/2015 12:00', "%d/%m/%Y %H:%M") }
      before { Timecop.freeze(date) }
      after { Timecop.return }

      context "southern hemisphere: Brasilia" do
        let(:tz) { ActiveSupport::TimeZone.new("Brasilia") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst_string.should eq("(GMT-03:00) Brasilia") }
      end

      context "northern hemisphere: London" do
        let(:tz) { ActiveSupport::TimeZone.new("London") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst_string.should eq("(GMT+01:00*) London") }
      end
    end

    context "in January" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      before { Timecop.freeze(date) }
      after { Timecop.return }

      context "southern hemisphere: Brasilia" do
        let(:tz) { ActiveSupport::TimeZone.new("Brasilia") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst_string.should eq("(GMT-02:00*) Brasilia") }
      end

      context "northern hemisphere: London" do
        let(:tz) { ActiveSupport::TimeZone.new("London") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst_string.should eq("(GMT+00:00) London") }
      end
    end
  end

  describe "#dst?" do
    context "in August" do
      let(:date) { DateTime.strptime('05/08/2015 12:00', "%d/%m/%Y %H:%M") }
      before { Timecop.freeze(date) }
      after { Timecop.return }

      context "southern hemisphere: Brasilia" do
        let(:tz) { ActiveSupport::TimeZone.new("Brasilia") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst?.should be(false) }
      end

      context "northern hemisphere: London" do
        let(:tz) { ActiveSupport::TimeZone.new("London") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst?.should be(true) }
      end
    end

    context "in January" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      before { Timecop.freeze(date) }
      after { Timecop.return }

      context "southern hemisphere: Brasilia" do
        let(:tz) { ActiveSupport::TimeZone.new("Brasilia") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst?.should be(true) }
      end

      context "northern hemisphere: London" do
        let(:tz) { ActiveSupport::TimeZone.new("London") }
        subject { Mconf::DSTTimezone.new(tz) }
        it { subject.dst?.should be(false) }
      end
    end
  end
end
