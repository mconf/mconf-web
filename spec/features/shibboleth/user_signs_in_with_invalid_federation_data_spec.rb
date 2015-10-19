# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe 'User signs in via shibboleth' do
  subject { page }

  context 'missing shib data' do
    context 'all of the fields' do
      before {
        # Same as enable_shib, but let's not use the conventional attribute names
        # to test this possibility
        @required = ['Ninjas', 'Pirates', 'Zombies']
        Site.current.update_attributes(
          :shib_enabled => true,
          :shib_name_field => @required[1],
          :shib_email_field => @required[0],
          :shib_principal_name_field => @required[2]
        )
        visit shibboleth_path
      }

      it { should have_content @required.inspect }
      it { should have_title t('shibboleth.attribute_error.page_title') }
      it { should have_css '#shibboleth-error' }
      it { should have_content t('shibboleth.attribute_error.informed.no_attrs') }
    end

    shared_examples "like it's missing fields" do
      before {
        @required = ["Shib-inetOrgPerson-mail", "Shib-inetOrgPerson-cn", "Shib-eduPerson-eduPersonPrincipalName"]
        setup_shib values[1], values[0], values[2]

        enable_shib
        visit shibboleth_path
      }

      it { should have_content @required.inspect }
      it { should have_title t('shibboleth.attribute_error.page_title') }
      it { should have_css '#shibboleth-error' }
      it { should have_content "#{@required[0].inspect}=>#{values[0].inspect}" }
      it { should have_content "#{@required[1].inspect}=>#{values[1].inspect}" }
      it { should have_content "#{@required[2].inspect}=>#{values[2].inspect}" }
    end

    context 'email field' do
      let(:values) { [nil, 'some name', 'principal name'] }
      include_examples "like it's missing fields"
    end

    context 'name field' do
      let(:values) { ['some@email.com', nil, 'principal name'] }
      include_examples "like it's missing fields"
    end

    context 'principal name field' do
      let(:values) { ['some@email.com', 'some name', nil] }
      include_examples "like it's missing fields"
    end

    context 'email and principal name' do
      let(:values) { [nil, 'some name', nil] }
      include_examples "like it's missing fields"
    end

  end
end
