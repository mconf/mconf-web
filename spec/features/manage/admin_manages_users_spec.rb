# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

describe 'Admin manages users' do
  subject { page }

  context 'with require registration approval disabled' do

    let(:admin) { User.first } # admin is already created
    before {
      Site.current.update_attributes(require_registration_approval: true)

      login_as(admin, :scope => :user)
      @user1 = FactoryGirl.create(:user)
      @user_admin = FactoryGirl.create(:user, superuser: true)
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

      it { should have_css '#users-list .list-item', count: 8 }
      it { should have_css '#users-list .icon-mconf-delete', count: 7 }

      it { should have_css '#users-list .list-item.list-item-disabled', count: 2 }
      it { should have_css '#users-list .icon-mconf-enable', count: 2 }

      it { should have_css '#users-list .icon-mconf-confirm-user', count: 2 }
      it { should have_css '#users-list .icon-mconf-approve', count: 2 }
      it { should have_css '#users-list .icon-mconf-superuser', count: 2 }

      context 'elements for the signed in user' do
        let(:user) { admin }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.icon-mconf-superuser' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_edit_user(user) }
        it { should_not have_link_to_destroy_user(user) }
        it { should_not have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
        it { subject.find('.user-username').should have_content(user.username) }
        it { subject.find('.user-name').should have_content(user.full_name) }
        it { subject.find('.user-email').should have_content(user.email) }
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
        it { subject.find('.user-username').should have_content(user.username) }
        it { subject.find('.user-name').should have_content(user.full_name) }
        it { subject.find('.user-email').should have_content(user.email) }
      end

      context 'elements for an admin' do
        let(:user) { @user_admin }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.icon-mconf-superuser' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
        it { subject.find('.user-username').should have_content(user.username) }
        it { subject.find('.user-name').should have_content(user.full_name) }
        it { subject.find('.user-email').should have_content(user.email) }
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
        it { subject.find('.user-username').should have_content(user.username) }
        it { subject.find('.user-name').should have_content(user.full_name) }
        it { subject.find('.user-email').should have_content(user.email) }
      end

      context 'elements for an unconfirmed normal user' do
        let!(:user) { @unconfirmed_user }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should have_link_to_confirm_user(user) }
        it { subject.find('.user-username').should have_content(user.username) }
        it { subject.find('.user-name').should have_content(user.full_name) }
        it { subject.find('.user-email').should have_content(user.email) }
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
        let(:user) { @user_admin }
        subject { page.find("#user-#{user.permalink}") }

        it { should have_css '.management-links' }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disapprove_user(user) }
        it { should have_css '.icon-mconf-superuser' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_disable_user(user) }
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
