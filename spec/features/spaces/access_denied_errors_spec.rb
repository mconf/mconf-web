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

      it { current_path.should eq login_path }
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

  context 'while accessing the edit page of a public space' do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space, public: true) }
    subject { page }

    context 'and is logged out' do
      before { visit edit_space_path(space) }

      it { current_path.should eq login_path }
    end

    context 'and is a logged in non-member' do
      before {
        login_as(user, :scope => :user)
        visit edit_space_path(space)
      }

      it { current_path.should eq(new_space_join_request_path(space)) }
    end

    context 'and is a logged in member' do
      before {
        space.add_member!(user)
        login_as(user, :scope => :user)
        visit edit_space_path(space)
      }

      it { current_path.should eq(space_path(space)) }
      it { should have_title(space.name) }
      it { should have_title(Site.current.name) }
      it { should have_css('body.spaces.show') }
      it { should have_content(t('spaces.error.need_join_to_access')) }
    end
  end
end
