require 'spec_helper'
require 'support/feature_helpers'

# For sanitize helpers
include ActionView::Helpers::SanitizeHelper

feature 'User hits access denied errors' do

  context 'while accessing a private space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space, :public => false) }
    subject { page }

    context 'and is logged out' do
      before { visit space_path(space) }

      it { should have_content(t('space.access_forbidden')) }
      it { should have_content(
        strip_links(
          t('space.is_private_html', name: space.name, path: new_space_join_request_path(space))
        ))
      }
      it { should have_link('', new_space_join_request_path(space)) }
      it { page.status_code.should == 403 }
    end

    context 'and is a logged in non-member' do
      before {
        login_as(user, :scope => :user)
        visit space_path(space)
      }

      it { current_path.should eq(new_space_join_request_path(space)) }
    end

    context 'and is a logged in member' do
      before {
        space.add_member!(user)
        login_as(user, :scope => :user)
        visit space_path(space)
      }

      it { current_path.should eq(space_path(space)) }
      it { should have_title(space.name) }
      it { should have_title(Site.current.name) }
      it { should have_css('body.spaces.show') }
    end
  end
end
