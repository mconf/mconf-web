require 'spec_helper'
require 'support/feature_helpers'

# For sanitize helpers
include ActionView::Helpers::SanitizeHelper

feature 'User hits access denied errors' do

  context 'while accessing the news index' do
    context 'in a public space' do
      let(:user) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:space_with_associations, public: true) }
      subject { page }

      context 'and is logged out' do
        before { visit space_news_index_path(space) }
        it { current_path.should eq '/users/login' }
      end

      context 'and is logged as a non-member' do
        before {
          login_as(user, scope: :user)
          visit space_news_index_path(space)
        }

        it { should_be_403_page }
      end

      context 'and is logged as a member' do
        before {
          space.add_member!(user)
          login_as(user, scope: :user)
          visit space_news_index_path(space)
        }

        it { should_be_403_page }
      end

      context 'and is logged as an admin' do
        before {
          space.add_member!(user, 'Admin')
          login_as(user, scope: :user)
          visit space_news_index_path(space)
        }

        it { current_path.should eq(space_news_index_path(space)) }
        it { should have_title(Site.current.name) }
        it { should have_css('body.news.index') }
      end
    end

    context 'in a private space' do
      let(:user) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:space_with_associations, public: false) }
      subject { page }

      context 'and is logged out' do
        before { visit space_news_index_path(space) }

        it { current_path.should eq '/users/login' }
      end

      context 'and is logged as a non-member' do
        before {
          login_as(user, scope: :user)
          visit space_news_index_path(space)
        }

        it { should_be_403_page }
      end

      context 'and is logged as a member' do
        before {
          space.add_member!(user)
          login_as(user, scope: :user)
          visit space_news_index_path(space)
        }

        it { should_be_403_page }
      end

      context 'and is logged as an admin' do
        before {
          space.add_member!(user, 'Admin')
          login_as(user, scope: :user)
          visit space_news_index_path(space)
        }

        it { current_path.should eq(space_news_index_path(space)) }
        it { should have_title(Site.current.name) }
        it { should have_css('body.news.index') }
      end
    end
  end
end
