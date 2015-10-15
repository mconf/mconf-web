# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"
require "support/feature_helpers"

def create_space_from_attrs attrs
  visit new_space_path
  fill_in "space[name]", with: attrs[:name]
  fill_in "space[permalink]", with: attrs[:permalink]
  fill_in "space[description]", with: attrs[:description]

  if attrs[:public] == true
    check "space[public]"
  else
    uncheck "space[public]"
  end

  click_button t("_other.create")
end

feature "Creating a space" do
  let(:user) { FactoryGirl.create(:user) }

  context "as public" do
    let(:attrs) { FactoryGirl.attributes_for(:space, public: true) }
    before {
      login_as(user, :scope => :user)
      create_space_from_attrs(attrs)
    }

    it { Space.last.public.should be(true) }
    it { current_path.should eq(space_path(Space.last)) }
    it { page.should have_content(attrs[:name]) }
    it { page.should have_content(attrs[:description]) }
    it { page.should have_content(t("layouts.spaces_page_title.public")) }
  end

  context "as private" do
    let(:attrs) { FactoryGirl.attributes_for(:space, public: false) }
    before {
      login_as(user, :scope => :user)
      create_space_from_attrs(attrs)
    }

    it { Space.last.public.should be(false) }
    it { current_path.should eq(space_path(Space.last)) }
    it { page.should have_content(attrs[:name]) }
    it { page.should have_content(attrs[:description]) }
    it { page.should have_content(t("layouts.spaces_page_title.private")) }
  end

  context "creation errors" do
    let(:space) { FactoryGirl.create(:space) }
    let(:attrs) { FactoryGirl.attributes_for(:space) }

    context "with the name of an existing space" do
      before {
        login_as(user, :scope => :user)
        attrs[:name] = space.name
        create_space_from_attrs(attrs)
      }

      it { current_path.should eq(spaces_path) }
      it { has_field_with_error "space_name" }
    end

    context "with the permalink of an existing space" do
      before {
        login_as(user, :scope => :user)
        attrs[:permalink] = space.permalink
        create_space_from_attrs(attrs)
      }

      it { current_path.should eq(spaces_path) }
      it { has_field_with_error "space_permalink" }
    end

    context "with the name of a disabled space" do
      before {
        disabled_space = FactoryGirl.create(:space, disabled: true)
        login_as(user, :scope => :user)

        attrs[:name] = disabled_space.name
        create_space_from_attrs(attrs)
      }

      it { current_path.should eq(spaces_path) }
      it { has_field_with_error "space_name" }
    end

    context "with the permalink of a disabled space" do
      before {
        disabled_space = FactoryGirl.create(:space, disabled: true)
        login_as(user, :scope => :user)

        attrs[:permalink] = disabled_space.permalink
        create_space_from_attrs(attrs)
      }

      it { current_path.should eq(spaces_path) }
      it { has_field_with_error "space_permalink" }
    end

    context "with the permalink equal to some user's username" do
      before {
        login_as(user, :scope => :user)

        attrs[:permalink] = user.username
        create_space_from_attrs(attrs)
      }

      it { current_path.should eq(spaces_path) }
      it { has_field_with_error "space_permalink" }
    end

    context "with the permalink equal to some disabled user's username" do
      before {
        disabled_user = FactoryGirl.create(:user, disabled: true)
        login_as(user, :scope => :user)

        attrs[:permalink] = disabled_user.username
        create_space_from_attrs(attrs)
      }

      it { current_path.should eq(spaces_path) }
      it { has_field_with_error "space_permalink" }
    end

  end

  context "when user space creation is moderated" do
    let(:attrs) { FactoryGirl.attributes_for(:space) }
    before {
      Site.current.update_attributes(require_space_approval: true)
      login_as(user, :scope => :user)
      create_space_from_attrs(attrs)
    }

    it { Space.last.should_not be_approved }
    it { current_path.should eq(space_path(Space.last)) }
    it { has_success_message t('space.created_waiting_moderation') }
    it { page.should have_content(attrs[:name]) }

    context '' do
      before { visit spaces_path(my_spaces: 'true', order: 'abc') }

      it { page.should have_content(attrs[:name]) }
      it { page.should have_selector('.space-waiting-moderation', count: 1) }
      it { page.should have_selector('.icon-mconf-waiting-moderation', count: 1)}
    end
  end

  context "when space creation is moderated but as an admin" do
    let(:attrs) { FactoryGirl.attributes_for(:space) }
    before {
      Site.current.update_attributes(require_space_approval: true)
      user.update_attributes(superuser: true)
      login_as(user, :scope => :user)
      create_space_from_attrs(attrs)
    }

    it { Space.last.should be_approved }
    it { current_path.should eq(space_path(Space.last)) }
  end

  context "when user space creation is disabled" do
    let(:attrs) { FactoryGirl.attributes_for(:space) }
    before {
      Site.current.update_attributes(forbid_user_space_creation: true)
      login_as(user, :scope => :user)

      visit spaces_path
    }
    it { expect{ find_link('', href: new_space_path) }.to  raise_error }

    context '' do
      before { visit new_space_path }

      it { current_path.should eq(spaces_path) }
      it { has_failure_message t('spaces.error.creation_forbidden') }
    end
  end

  context "when space creation is disabled but as an admin" do
    before {
      Site.current.update_attributes(forbid_user_space_creation: true)
      user.update_attributes(superuser: true)
      login_as(user, :scope => :user)
      visit spaces_path
    }

    it { page.find_link('', href: new_space_path).should be_visible }

    context '' do
      before { visit new_space_path }
      it { current_path.should eq(new_space_path) }
    end
  end

  # Skipping because with_js is not working properly yet
  skip "generates a valid suggestion for the identifier", with_js: true do
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: "Mr. Pink-man's #1 (5% of tries = WIN, \"haha\"): áéíôü"

    expected = "mr-pink-mans-1-5-of-tries-win-haha-aeiou"
    find_field('space[permalink]').value.should eql(expected)
  end

end
