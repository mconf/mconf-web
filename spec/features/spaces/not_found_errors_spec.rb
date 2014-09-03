require 'spec_helper'
require 'support/feature_helpers'

# For sanitize helpers
include ActionView::Helpers::SanitizeHelper

feature 'User accesses an URL of a space that' do

  context 'does exist' do
    let(:space) { FactoryGirl.create(:space, :public => true) }
    before { visit space_path(space) }
    subject { page }

    it { should have_title(space.name) }
    it { should have_content(space.name) }
    it { page.status_code.should == 200 }
  end

  context 'does not exist' do
    before { visit space_path(:id => 'nonexistent') }
    subject { page }

    it { should have_title(t('error.e404.title')) }
    it { should have_content(t('error.e404.title')) }
    it { should have_content(
      strip_tags(t('spaces.error.not_found', :permalink => 'nonexistent', :path => spaces_path))
      )
    }
    it { should have_link('', :href => spaces_path) }
    it { page.status_code.should == 404 }
  end

end
