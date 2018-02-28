# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2018 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

describe 'Admin manages statistics' do
  let(:admin) { User.first } # admin is already created
  subject { page }

  before(:each) do
    login_as(admin, :scope => :user)
    visit manage_statistics_path
  end

  context " testing buttons" do
    it { should have_css '.btn-default', :count => 3 }
    it { should have_css '.btn-primary', :count => 1 }
    it { should have_css '.icon-date', :count => 1 }
  end

  context "testing content" do
    it { should have_content(I18n.t('manage.statistics.csv')) }

    context "users" do
      it { should have_content(I18n.t('manage.statistics_list.users.title')) }
      it { should have_content(I18n.t('manage.statistics_list.users.all', value: 1)) }
    end

    context "spaces" do
      it { should have_content(I18n.t('manage.statistics_list.spaces.title')) }
      it { should have_content(I18n.t('manage.statistics_list.spaces.all', value: 0)) }
    end

    context "meetings" do
      it { should have_content(I18n.t('manage.statistics_list.meetings.title')) }
      it { should have_content(I18n.t('manage.statistics_list.meetings.all', value: 0)) }
    end

    context "recordings" do
      it { should have_content(I18n.t('manage.statistics_list.recordings.title')) }
      it { should have_content(I18n.t('manage.statistics_list.recordings.all', value: 0)) }
    end
  end
end
