# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

describe 'Admin manages users' do
  subject { page }
  let(:admin) { User.first } # admin is already created

  context 'with require registration approval disabled' do

    context 'listing users in management screen' do
      before {
        login_as(admin, :scope => :user)
        @user1 = FactoryGirl.create(:user)
        @user1.update_attributes(can_record: true)
        @user_admin = FactoryGirl.create(:superuser)
        @unapproved_user = FactoryGirl.create(:user)
        @unapproved_user.update_attributes(:approved => false)
        @disabled_user1 = FactoryGirl.create(:user, disabled: true)
        @disabled_user2 = FactoryGirl.create(:user, disabled: true)
        @unconfirmed_user = FactoryGirl.create(:unconfirmed_user)
        @unconfirmed_unapproved_user = FactoryGirl.create(:unconfirmed_user)
        @unconfirmed_unapproved_user.update_attributes(:approved => false)
      }

      before { visit manage_users_path }

      it { should have_css '#users-list .list-item', count: 8 }
      it { should have_css '#users-list .icon-delete', count: 7 }

      it { should have_css '#users-list .list-item.list-item-disabled', count: 2 }
      it { should have_css '#users-list .icon-enable', count: 2 }

      it { should have_css '#users-list .icon-confirm-user', count: 2 }
      it { should have_css '#users-list .icon-approve', count: 2 }
      it { should have_css '#users-list .icon-superuser', count: 2 }
      it { should have_css '#users-list .icon-cant-rec', :count => 5 }
      it { should have_css '#users-list .icon-can-rec', :count => 1 }

      context 'elements for the signed in user' do
        let(:user) { admin }
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.icon-superuser' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_edit_user(user) }
        it { should_not have_link_to_destroy_user(user) }
        it { should_not have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
        it { subject.should have_content(user.username) }
        it { subject.should have_content(user.full_name) }
        it { subject.should have_content(user.email) }
        it { should have_content user.last_sign_in_method }
        it { should have_content I18n.l(user.current_sign_in_at.in_time_zone, format: :numeric) }
      end

      context 'elements for a normal user' do
        let(:user) { @user1 }
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.icon-user' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.normal_user') }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
        it { subject.should have_content(user.username) }
        it { subject.should have_content(user.full_name) }
        it { subject.should have_content(user.email) }
      end

      context 'elements for an admin' do
        let(:user) { @user_admin }
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.icon-superuser' }
        it { should have_css '.management-links' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
        it { subject.should have_content(user.username) }
        it { subject.should have_content(user.full_name) }
        it { subject.should have_content(user.email) }
      end

      context 'elements for a disabled user' do
        let(:user) { @disabled_user1 }
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.management-links' }
        it { should have_link_to_enable_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should_not have_link_to_edit_user(user) }
        it { should_not have_link_to_disable_user(user) }
        it { should_not have_link_to_confirm_user(user) }
        it { subject.should have_content(user.username) }
        it { subject.should have_content(user.full_name) }
        it { subject.should have_content(user.email) }
      end

      context 'elements for an unconfirmed normal user' do
        let!(:user) { @unconfirmed_user }
        subject { page.find("#user-#{user.slug}") }

        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should have_link_to_confirm_user(user) }
        it { subject.should have_content(user.username) }
        it { subject.should have_content(user.full_name) }
        it { subject.should have_content(user.email) }
      end
    end

    context 'with require registration approval enabled' do
      before {
        Site.current.update_attributes(require_registration_approval: true)

        login_as(admin, :scope => :user)
        @user1 = FactoryGirl.create(:user)
        @user_admin = FactoryGirl.create(:superuser)
        @unapproved_user = FactoryGirl.create(:user)
        @unapproved_user.update_attributes(:approved => false)
        @disabled_user1 = FactoryGirl.create(:user, disabled: true)
        @disabled_user2 = FactoryGirl.create(:user, disabled: true)
        @unconfirmed_user = FactoryGirl.create(:unconfirmed_user)
        @unconfirmed_unapproved_user = FactoryGirl.create(:unconfirmed_user)
        @unconfirmed_unapproved_user.update_attributes(:approved => false)

        visit manage_users_path
      }

      context 'elements for a normal approved user' do
        let(:user) { @user1 }
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.management-links' }
        it { should have_link_to_disapprove_user(user) }
        it { should have_link_to_destroy_user(user) }
      end

      context 'elements for an approved admin user' do
        let(:user) { User.first }
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.management-links' }
        it { should_not have_link_to_disapprove_user(user) }
        it { should_not have_link_to_destroy_user(user) }
      end

      context 'elements for a unapproved user' do
        let(:user) { @unapproved_user }
        subject { page.find("#user-#{user.slug}") }

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
        subject { page.find("#user-#{user.slug}") }

        it { should have_css '.management-links' }
        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disapprove_user(user) }
        it { should have_css '.icon-superuser' }
        it { should have_content t('_other.user.administrator') }
        it { should have_link_to_disable_user(user) }
      end

      context 'elements for an unapproved and unconfirmed user' do
        let!(:user) { @unconfirmed_unapproved_user }
        subject { page.find("#user-#{user.slug}") }

        it { should have_link_to_edit_user(user) }
        it { should have_link_to_destroy_user(user) }
        it { should have_link_to_disable_user(user) }
        it { should have_link_to_confirm_user(user) }
        it { should_not have_link_to_disapprove_user(user) }
        it { should have_link_to_approve_user(user) }
      end
    end

    context 'checking the Login Methods and Last Login Date' do
      before {
        login_as(admin, scope: :user)

        @user_local = FactoryGirl.create(:user, username: 'el-magron')
        @user_ldap = FactoryGirl.create(:ldap_token, identifier: 'el-ldap', new_account: true).user
        @user_shib = FactoryGirl.create(:shib_token, identifier: 'el-shib', new_account: true).user
        @user_ldap_local = FactoryGirl.create(:ldap_token, identifier: 'el-ldap-e-local', new_account: false).user
        @user_shib_local = FactoryGirl.create(:shib_token, identifier: 'el-shib-e-local', new_account: false).user
        @user_ldap_shib_local = FactoryGirl.create(:shib_token, identifier: 'el-shib-e-ldap-e-local', new_account: false).user
        FactoryGirl.create(:ldap_token, user: @user_ldap_shib_local)
      }

      context 'listing users in management screen' do
        before { visit manage_users_path }

        it { should have_css '.list-item', count: 7 }
        it { should have_css '.icon-delete', count: 6 }
        it { should have_css '.icon-superuser', count: 1 }

        it { should have_content @user_local.full_name }
        it { should have_content @user_ldap.full_name }
        it { should have_content @user_shib.full_name }
        it { should have_content @user_ldap_local.full_name }
        it { should have_content @user_shib_local.full_name }
        it { should have_content @user_ldap_shib_local.full_name }

        context 'elements for admin' do
          let(:user) { User.first }
          subject { page.find("#user-#{user.slug}") }

          it { should have_content user.last_sign_in_method }
          it { should have_content I18n.l(user.current_sign_in_at.in_time_zone, format: :numeric) }
        end

        context 'elements for a local user' do
          let(:user) { @user_local }
          subject { page.find("#user-#{user.slug}") }

          it { subject.find(".user-login").should have_content User.last.sign_in_method_name }
          it { should have_css "[title='#{t('.manage.user_item.never_sign_in')}']" }
        end

        context 'elements for a shib user' do
          let(:user) { @user_shib }
          subject { page.find("#user-#{user.slug}") }

          it { subject.find(".user-login").should_not have_content User.last.sign_in_method_name }
          it { subject.find(".user-login").should have_content ShibToken.last.sign_in_method_name }
          it { subject.find(".user-login").should_not have_content LdapToken.last.sign_in_method_name }
          it { should have_css "[title='#{t('.manage.user_item.never_sign_in')}']" }
          it { should have_content t('_other.auth.shibboleth') }
          it { should_not have_content t('_other.auth.local') }
        end

        context 'elements for a ldap user' do
          let(:user) { @user_ldap }
          subject { page.find("#user-#{user.slug}") }

          it { subject.find(".user-login").should_not have_content User.last.sign_in_method_name }
          it { subject.find(".user-login").should_not have_content ShibToken.last.sign_in_method_name }
          it { subject.find(".user-login").should have_content LdapToken.last.sign_in_method_name }
          it { should have_css "[title='#{t('.manage.user_item.never_sign_in')}']" }
        end

        context 'elements for a shib and local user' do
          let(:user) { @user_shib_local }
          subject { page.find("#user-#{user.slug}") }

          it { subject.find(".user-login").should have_content User.last.sign_in_method_name }
          it { subject.find(".user-login").should have_content ShibToken.last.sign_in_method_name }
          it { subject.find(".user-login").should_not have_content LdapToken.last.sign_in_method_name }
          it { should have_css "[title='#{t('.manage.user_item.never_sign_in')}']" }
        end

        context 'elements for a ldap and local user' do
          let(:user) { @user_ldap_local }
          subject { page.find("#user-#{user.slug}") }

          it { subject.find(".user-login").should have_content User.last.sign_in_method_name }
          it { subject.find(".user-login").should_not have_content ShibToken.last.sign_in_method_name }
          it { subject.find(".user-login").should have_content LdapToken.last.sign_in_method_name }
          it { should have_css "[title='#{t('.manage.user_item.never_sign_in')}']" }
        end

        context 'elements for a shib and ldap and local user' do
          let(:user) { @user_ldap_shib_local }
          subject { page.find("#user-#{user.slug}") }

          it { subject.find(".user-login").should have_content User.last.sign_in_method_name }
          it { subject.find(".user-login").should have_content ShibToken.last.sign_in_method_name }
          it { subject.find(".user-login").should have_content LdapToken.last.sign_in_method_name }
          it { should have_css "[title='#{t('.manage.user_item.never_sign_in')}']" }
        end
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
