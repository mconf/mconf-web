require 'spec_helper'
require 'support/feature_helpers'

describe 'Admin manages users' do
  subject { page }

  context 'with require registration approval disabled' do

    let(:admin) { User.first } # admin is already created
    before {
      login_as(admin, :scope => :user)
      @user1 = FactoryGirl.create(:user)
      @unapproved_user = FactoryGirl.create(:user)
      @unapproved_user.update_attributes(:approved => false)
      @disabled_user1 = FactoryGirl.create(:user, disabled: true)
      @disabled_user2 = FactoryGirl.create(:user, disabled: true)
      @unconfirmed_user = FactoryGirl.create(:unconfirmed_user)
      @unconfirmed_unapproved_user = FactoryGirl.create(:unconfirmed_user)
      @unconfirmed_unapproved_user.update_attributes(:approved => false)
    }

    context 'listing users in management screen' do
      before { visit manage_users_path }

      it { should have_css '.user-simple', :count => 7 }
      it { should have_css '.icon-mconf-delete', :count => 6 }
      it { should have_css '.user-disabled', :count => 2 }
      it { should have_css '.icon-mconf-superuser', :count => 1 }

      it { should have_content user_description(@user1) }
      it { should have_content user_description(@unapproved_user) }
      it { should have_content user_description(@disabled_user1) }
      it { should have_content user_description(@disabled_user2) }
      it { should have_content user_description(@unconfirmed_user) }
      it { should have_content user_description(@unconfirmed_unapproved_user) }

      context 'elements for an admin user (self)' do
        let(:user) { admin }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.icon-mconf-superuser' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_edit_user(user) }
        it { should_not have_link_to_destroy_user(user) }
        it { should_not have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
      end

      context 'elements for a normal user' do
        let(:user) { @user1 }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.icon-mconf-user' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.normal_user') }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
      end

      context 'elements for a disabled user' do
        let(:user) { @disabled_user1 }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link_to_enable_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should_not have_link_to_edit_user(user) }
        it { should_not have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
      end

      context 'elements for an unconfirmed normal user' do
        let!(:user) { @unconfirmed_user }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should have_link_to_confirm_user(user) }
      end
    end

    context 'with require registration approval enabled' do
      before {
        Site.current.update_attributes(:require_registration_approval => true)
        visit manage_users_path
      }

      context 'elements for a normal approved user' do
        let(:user) { @user1 }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link_to_disapprove_user(user) }
        it { should have_link_to_destroy_user(user) }
      end

      context 'elements for an approved admin user' do
        let(:user) { User.first }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should_not have_link_to_disapprove_user(user) }
        it { should_not have_link_to_destroy_user(user) }
      end

      context 'elements for a unapproved user' do
        let(:user) { @unapproved_user }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should_not have_link_to_disapprove_user(user) }
        it { should have_link_to_approve_user(user) }
        it { should have_content t('_other.user.unapproved_user') }
        it { should have_css '.user-unapproved'}
      end

      context 'elements for a second approved admin user' do
        let(:user) { @user1 }
        before {
          user.update_attributes(:superuser => true)
          visit manage_users_path
        }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link_to_edit_user(user) }
        it { should_not have_link_to_destroy_user(user) }
        it { should_not have_link_to_disapprove_user(user) }
        it { should have_css '.icon-mconf-superuser' }
        it { should have_content t('_other.user.administrator') }
        it { should_not have_link_to_disable_user(user) }
      end

      context 'elements for an unapproved and unconfirmed user' do
        let!(:user) { @unconfirmed_unapproved_user }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should have_link_to_confirm_user(user) }
        it { should_not have_link_to_disapprove_user(user) }
        it { should have_link_to_approve_user(user) }
      end
    end

  end
end

def have_link_to_edit_user(user)
  have_link '', :href => edit_user_path(user)
end

def have_link_to_destroy_user(user)
  have_css("a[href='#{user_path(user)}'][data-method='delete']")
end

def have_link_to_disable_user(user)
  have_css("a[href='#{disable_user_path(user)}'][data-method='delete']")
end

def have_link_to_confirm_user(user)
  have_css("a[href='#{confirm_user_path(user)}'][data-method='post']")
end

def have_link_to_enable_user(user)
  have_link '', :href => enable_user_path(user)
end

def have_link_to_disapprove_user(user)
  have_link '', :href => disapprove_user_path(user)
end

def have_link_to_approve_user(user)
  have_link '', :href => approve_user_path(user)
end

def user_description(user)
  "#{user.full_name} (#{user.username}, #{user.email})"
end
