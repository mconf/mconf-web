# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe AttributeCertificateConfiguration do

  describe '#valid?' do
    context 'without enabled flag' do
      let(:config) { FactoryGirl.build(:attr_conf, enabled: false)}

      it { config.should be_valid }
    end

    context 'with enabled flag and valid urls' do
      let(:config) { FactoryGirl.build(:attr_conf, enabled: true) }

      it { config.should be_valid }
    end

    context 'with enabled flag and no url' do
      let(:config) { FactoryGirl.build(:attr_conf, enabled: true, repository_url: nil) }

      it { config.should_not be_valid }
    end

    context 'with enabled flag and valid urls and no port' do
      let(:config) { FactoryGirl.build(:attr_conf, enabled: true, repository_port: nil) }

      it { config.should be_valid }
    end

  end

  describe '.full_url' do
    let(:config) { FactoryGirl.build(:attr_conf, repository_url: 'hidden.ninja') }

    context 'with a ssl site' do
      before { config.repository_port = '443' }
      it { config.full_url.should eq('https://hidden.ninja?wsdl') }
    end

    context 'with an http site' do
      before { config.repository_port = '80' }
      it { config.full_url.should eq('http://hidden.ninja?wsdl') }
    end

    context 'with no port set default to ssl' do
      before { config.repository_port = nil }
      it { config.full_url.should eq('https://hidden.ninja?wsdl') }
    end

    context 'with a random port' do
      before { config.repository_port = '13377' }
      it { config.full_url.should eq('http://hidden.ninja:13377/?wsdl') }
    end
  end

  describe 'before_save correct url' do

    context 'with wsdl and http' do
      let(:config) { FactoryGirl.create(:attr_conf, repository_url: 'http://deadly.ninja?wsdl', repository_port: '80') }

      it { config.repository_url.should eq('deadly.ninja') }
      it { config.full_url.should eq('http://deadly.ninja?wsdl') }
    end

    context 'with wsdl and https' do
      let(:config) { FactoryGirl.create(:attr_conf, repository_url: 'https://deadly.ninja?wsdl', repository_port: '443') }

      it { config.repository_url.should eq('deadly.ninja') }
      it { config.full_url.should eq('https://deadly.ninja?wsdl') }
    end

    context 'without protocol and wsdl' do
      let(:config) { FactoryGirl.create(:attr_conf, repository_url: 'deadly.ninja', repository_port: '443') }

      it { config.repository_url.should eq('deadly.ninja') }
      it { config.full_url.should eq('https://deadly.ninja?wsdl') }
    end

    context 'with wsdl and protocol in other parts of the string' do
      let(:config) { FactoryGirl.create(:attr_conf, repository_url: 'wsdleadlyhttps.ninja?wsdl', repository_port: '443') }

      it { config.repository_url.should eq('wsdleadlyhttps.ninja') }
      it { config.full_url.should eq('https://wsdleadlyhttps.ninja?wsdl') }
    end

  end

end
