# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature 'Frontpage' do

  context 'visit landing page' do
    before { visit root_path }

    it { page.should have_content(Site.current.name) }
    it { page.should have_content(I18n.t('frontpage.show.register.title')) }
    it { page.should have_content(I18n.t('frontpage.show.login.title')) }
  end

end
