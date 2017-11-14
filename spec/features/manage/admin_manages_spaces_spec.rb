# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

describe 'Admin manages spaces' do
  subject { page }

  context 'with require registration approval disabled' do

    let(:admin) { User.first } # admin is already created
    before {
      Site.current.update_attributes(require_registration_approval: true)

      login_as(admin, :scope => :user)
      @approved_space = FactoryGirl.create(:space, :name => 'Approved', :approved => true, :description => "This space is approved")
      @approved_space.update_attributes(:tag_list => ["this one has tags", "two tags"])
      @not_approved_space = FactoryGirl.create(:space, :name => 'Not Approved', :approved => false, :description => "This space is not approved")
      @enabled_space = FactoryGirl.create(:space, :name => 'Enabled', :disabled => false, :description => "This space is enabled")
      @enabled_space.update_attributes(:tag_list => ["this one has a tag too"])
      @disabled_space =FactoryGirl.create(:space, :name => 'Disabled', :disabled => true, :description => "This space is disabled")
      @not_approved_space.disapprove!
    }

    context 'listing spaces in management screen' do
      before { visit manage_spaces_path }

      it { should have_css '.list-item', :count => 4 }
      it { should have_css '.icon-delete', :count => 4 }

      it { should have_css '.list-item-disabled', :count => 1 }
      it { should have_css '.icon-enable', :count => 1 }

      it { should have_css '.icon-edit', :count => 3 }
      it { should have_css '.icon-disable', :count => 3 }

      skip { should have_css '.label.label-tag', :count => 3 } # TODO
      skip { should have_content "this one has a tag too"} # TODO

      it { should have_content @approved_space.name }
      it { should have_content @approved_space.description }
      it { should have_content @not_approved_space.name }
      it { should have_content @not_approved_space.description }
      it { should have_content @enabled_space.name }
      it { should have_content @enabled_space.description }
      it { should have_content @disabled_space.name }
      it { should have_content @disabled_space.description }

      context 'elements for an approved space' do
        let(:space) { @approved_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should_not have_content t('._other.not_approved.text') }
        it { should have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_disable_space(space) }
        it { should_not have_link_to_approve_space(space) }
        it { should_not have_link_to_disapprove_space(space) }
      end

      context 'elements for a not approved space' do
        let(:space) { @not_approved_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should have_content t('._other.not_approved.text') }
        it { should have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_disable_space(space) }
        it { should have_link_to_approve_space(space) }
        it { should_not have_link_to_disapprove_space(space) }
      end

      context 'elements for a disabled space' do
        let(:space) { @disabled_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should_not have_css '.icon-edit' }
        it { should_not have_content t('._other.not_approved.text') }
        it { should_not have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_enable_space(space) }
        it { should_not have_link_to_disable_space(space) }
        it { should_not have_link_to_approve_space(space) }
        it { should_not have_link_to_disapprove_space(space) }
      end

      context 'elements for an enabled space' do
        let(:space) { @enabled_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should_not have_content t('._other.not_approved.text') }
        it { should have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_disable_space(space) }
        it { should_not have_link_to_approve_space(space) }
        it { should_not have_link_to_disapprove_space(space) }
      end
    end

    context 'with require registration approval enabled' do
      before {
        Site.current.update_attributes(:require_space_approval => true)
        visit manage_spaces_path
      }

      context 'elements for an approved space' do
        let(:space) { @approved_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should_not have_content t('._other.not_approved.text') }
        it { should have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_disable_space(space) }
        it { should_not have_link_to_approve_space(space) }
        it { should have_link_to_disapprove_space(space) }
      end

      context 'elements for a not approved space' do
        let(:space) { @not_approved_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should have_content t('._other.not_approved.text') }
        it { should have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_disable_space(space) }
        it { should_not have_link_to_disapprove_space(space) }
        it { should have_link_to_approve_space(space) }
      end

      context 'elements for a disabled space' do
        let(:space) { @disabled_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should_not have_css '.icon-edit' }
        it { should_not have_content t('._other.not_approved.text') }
        it { should_not have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_enable_space(space) }
        it { should_not have_link_to_disable_space(space) }
        it { should_not have_link_to_approve_space(space) }
        it { should_not have_link_to_disapprove_space(space) }
      end

      context 'elements for an enabled space' do
        let(:space) { @enabled_space }
        subject { page.find("#space-#{space.slug}") }

        it { should have_css '.logo-space' }
        it { should have_css '.management-links' }
        it { should_not have_content t('._other.not_approved.text') }
        it { should have_link_to_edit_space(space) }
        it { should have_link_to_destroy_space(space) }
        it { should have_link_to_disable_space(space) }
        it { should_not have_link_to_approve_space(space) }
        it { should have_link_to_disapprove_space(space) }
      end
    end
  end

  context 'spaces module is disabled' do
    let(:admin) { User.first } # admin is already created
    before {
      Site.current.update_attribute(:spaces_enabled, false)

      login_as(admin, :scope => :user)
      @s1 = FactoryGirl.create(:space, :name => 'First', :approved => true, :description => "This space is approved")
      @s2 = FactoryGirl.create(:space, :name => 'Second', :approved => true, :description => "This space is approved")

      visit manage_spaces_path
    }
    context 'no css should load and the page should 404' do
      it { should_not have_css '.list-item' }
      it { should_not have_css '.icon-delete' }
      it { should_not have_css '.list-item-disabled' }
      it { should_not have_css '.icon-enable' }
      it { should_not have_css '.icon-edit' }
      it { should_not have_css '.icon-disable'}
      it { page.status_code.should == 404 }
    end
  end

end

def have_link_to_edit_space(space)
  have_link '', :href => edit_space_path(space)
end

def have_link_to_destroy_space(space)
  have_css("a[href='#{space_path(space)}'][data-method='delete']")
end

def have_link_to_disable_space(space)
  have_css("a[href='#{disable_space_path(space)}'][data-method='delete']")
end

def have_link_to_enable_space(space)
  have_link '', :href => enable_space_path(space)
end

def have_link_to_disapprove_space(space)
  have_link '', :href => disapprove_space_path(space)
end

def have_link_to_approve_space(space)
  have_link '', :href => approve_space_path(space)
end
