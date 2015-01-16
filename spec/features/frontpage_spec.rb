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
