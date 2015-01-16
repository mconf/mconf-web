require 'spec_helper'
require 'support/feature_helpers'

feature 'Frontpage' do

  context 'visit landing page' do
    before { visit root_path }

    # UFRGS: the frontpage is different
    skip { page.should have_content(Site.current.name) }
    skip { page.should have_content(I18n.t('frontpage.show.register.title')) }
    skip { page.should have_content(I18n.t('frontpage.show.login.title')) }
    it { page.should have_link(t('frontpage.show.click_to_access'), href: shibboleth_path) }
  end

end
