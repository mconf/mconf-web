require 'spec_helper'
require 'support/feature_helpers'

feature 'User accesses an URL of a user that' do

  context 'does exist' do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    subject { page }

    it { should have_title(t('profile.header_title')) }
    it { should have_content(user.name) }
  end

  context 'does not exist' do
    before { visit user_path(:id => 'nonexistent') }
    subject { page }

    it { should have_title(t('error.e404.title')) }
    it { should have_content(t('error.e404.title')) }
    it { should have_content(t('error.e404.description', :url => user_path(:id => 'nonexistent'))) }
  end

end