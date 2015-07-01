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
  let!(:user) { FactoryGirl.create(:user) }

  scenario "as public" do
    attrs = FactoryGirl.attributes_for(:space, public: true)
    login_as(user, :scope => :user)

    create_space_from_attrs(attrs)

    Space.last.public.should be(true)
    current_path.should eq(space_path(Space.last))
    page.should have_content(attrs[:name])
    page.should have_content(attrs[:description])
    page.should have_content(t("layouts.spaces_page_title.public"))
  end

  scenario "as private" do
    attrs = FactoryGirl.attributes_for(:space, public: false)
    login_as(user, :scope => :user)

    create_space_from_attrs(attrs)

    Space.last.public.should be(false)
    current_path.should eq(space_path(Space.last))
    page.should have_content(attrs[:name])
    page.should have_content(attrs[:description])
    page.should have_content(t("layouts.spaces_page_title.private"))
  end

  context "creation errors " do
    let(:space) { FactoryGirl.create(:space) }
    let(:attrs) { FactoryGirl.attributes_for(:space) }

    scenario "with the name of an existing space" do
      login_as(user, :scope => :user)

      attrs[:name] = space.name
      create_space_from_attrs(attrs)

      current_path.should eq(spaces_path)
      has_field_with_error "space_name"
    end

    scenario "with the permalink of an existing space" do
      login_as(user, :scope => :user)

      attrs[:permalink] = space.permalink
      create_space_from_attrs(attrs)

      current_path.should eq(spaces_path)
      has_field_with_error "space_permalink"
    end

    scenario "with the name of a disabled space" do
      disabled_space = FactoryGirl.create(:space, disabled: true)
      login_as(user, :scope => :user)

      attrs[:name] = disabled_space.name
      create_space_from_attrs(attrs)

      current_path.should eq(spaces_path)
      has_field_with_error "space_name"
    end

    scenario "with the permalink of a disabled space" do
      disabled_space = FactoryGirl.create(:space, disabled: true)
      login_as(user, :scope => :user)

      attrs[:permalink] = disabled_space.permalink
      create_space_from_attrs(attrs)

      current_path.should eq(spaces_path)
      has_field_with_error "space_permalink"
    end

    scenario "with the permalink equal to some user's username" do
      login_as(user, :scope => :user)

      attrs[:permalink] = user.username
      create_space_from_attrs(attrs)

      current_path.should eq(spaces_path)
      has_field_with_error "space_permalink"
    end

    scenario "with the permalink equal to some disabled user's username" do
      disabled_user = FactoryGirl.create(:user, disabled: true)
      login_as(user, :scope => :user)

      attrs[:permalink] = disabled_user.username
      create_space_from_attrs(attrs)

      current_path.should eq(spaces_path)
      has_field_with_error "space_permalink"
    end

  end

  scenario "when user space creation is moderated" do
    Site.current.update_attributes(require_space_approval: true)
    login_as(user, :scope => :user)

    attrs = FactoryGirl.attributes_for(:space)

    create_space_from_attrs(attrs)

    Space.last.should_not be_approved
    current_path.should eq(spaces_path)
    has_success_message t('space.created_waiting_moderation')

    page.should_not have_content(attrs[:name])

    visit spaces_path(my_spaces: 'true')

    page.should have_content(attrs[:name])
    page.should have_selector('.waiting-approval', count: 1)
    page.should have_selector('.icon-mconf-waiting-moderation', count: 1)
  end

  scenario "when user space creation is disabled" do
    Site.current.update_attributes(forbid_user_space_creation: true)
    login_as(user, :scope => :user)

    visit spaces_path
    page.should_not have_link href: new_space_path

    visit new_space_path

    current_path.should eq(spaces_path)
    has_failure_message t('spaces.error.creation_forbidden')
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
