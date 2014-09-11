require 'spec_helper'
require 'support/feature_helpers'

describe 'Admin manages users' do
  subject { page }

  context 'with require registration approval disabled' do

    let(:admin) { User.first } # admin is already created
    before {
      login_as(admin, :scope => :user)
      @users = [
        FactoryGirl.create(:user),
        FactoryGirl.create(:user, :disabled => true),
        FactoryGirl.create(:user),
        FactoryGirl.create(:user, :disabled => true)
      ]
    }

    context 'listing users in management screen' do
      before { visit manage_users_path }

      it { should have_css '.user-simple', :count => 5 }
      it { should have_css '.user-disabled', :count => 2 }
      it { should have_css '.icon-mconf-superuser', :count => 1 }

      0.upto(3) do |i|
        it { should have_content "#{@users[i]._full_name} (#{@users[i].username}, #{@users[i].email})" }
      end

      context 'elements for an admin user (self)' do
        let(:user) { admin }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.icon-mconf-superuser' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link '', :href => edit_user_path(user) }
        it { should_not have_css("a[href='#{user_path(user)}'][data-method='delete']") }
      end

      context 'elements for a normal user' do
        let(:user) { @users[0] }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.icon-mconf-user' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.normal_user') }
        it { should have_link '', :href => edit_user_path(user) }
        it { should have_css("a[href='#{user_path(user)}'][data-method='delete']") }
      end

      context 'elements for a disabled user' do
        let(:user) { @users[1] }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should_not have_link '', :href => edit_user_path(user) }
        it { should have_link '', :href => enable_user_path(user) }
      end

    end

    context 'with require registration approval enabled' do
      before {
        Site.current.update_attributes(:require_registration_approval => true)
        @users[2].update_attributes(:approved => false)
        visit manage_users_path
      }

      context 'elements for a normal approved user' do
        let(:user) { @users[0] }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link '', :href => disapprove_user_path(user) }
      end

      context 'elements for an approved admin user' do
        let(:user) { User.first }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should_not have_link '', :href => disapprove_user_path(user) }
      end

      context 'elements for a unapproved user' do
        let(:user) { @users[2] }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link '', :href => edit_user_path(user) }
        it { should_not have_link '', :href => disapprove_user_path(user) }
        it { should have_link '', :href => approve_user_path(user) }
        it { should have_content t('_other.user.unapproved_user') }
        it { should have_css '.user-unapproved'}
      end

      context 'elements for a second approved admin user' do
        let(:user) { @users[0] }
        before {
          user.update_attributes(:superuser => true)
          visit manage_users_path
        }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link '', :href => edit_user_path(user) }
        it { should_not have_link '', :href => disapprove_user_path(user) }
        it { should have_css '.icon-mconf-superuser' }
        it { should have_content t('_other.user.administrator') }
        it { should_not have_css("a[href='#{user_path(user)}'][data-method='delete']") }
      end

    end

  end
end