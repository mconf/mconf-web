# -*- coding: utf-8 -*-
require "spec_helper"
require "support/feature_helpers"

feature "Creating a space" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:space) { FactoryGirl.create(:space) }

  scenario "as public" do
    attrs = FactoryGirl.attributes_for(:space)
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: attrs[:name]
    fill_in "space[permalink]", with: attrs[:permalink]
    fill_in "space[description]", with: attrs[:description]
    check "space[public]"
    click_button t("_other.create")

    Space.last.public.should be(true)
    current_path.should eq(space_path(Space.last))
    page.should have_content(attrs[:name])
    page.should have_content(attrs[:description])
    page.should have_content(t("layouts.spaces_page_title.public"))
  end

  scenario "as private" do
    attrs = FactoryGirl.attributes_for(:space)
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: attrs[:name]
    fill_in "space[permalink]", with: attrs[:permalink]
    fill_in "space[description]", with: attrs[:description]
    uncheck "space[public]"
    click_button t("_other.create")

    Space.last.public.should be(false)
    current_path.should eq(space_path(Space.last))
    page.should have_content(attrs[:name])
    page.should have_content(attrs[:description])
    page.should have_content(t("layouts.spaces_page_title.private"))
  end

  scenario "with the name of an existing space" do
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: space.name
    fill_in "space[permalink]", with: "anything"
    fill_in "space[description]", with: "Anything"
    click_button t("_other.create")

    current_path.should eq(spaces_path)
    has_field_with_error "space_name"
  end

  scenario "with the permalink of an existing space" do
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in 'space[name]', with: "Anything"
    fill_in 'space[permalink]', with: space.permalink
    fill_in 'space[description]', with: "Anything"
    click_button t("_other.create")

    current_path.should eq(spaces_path)
    has_field_with_error "space_permalink"
  end

  scenario "with the name of a disabled space" do
    disabled_space = FactoryGirl.create(:space, disabled: true)
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: disabled_space.name
    fill_in "space[permalink]", with: "anything"
    fill_in "space[description]", with: "Anything"
    click_button t("_other.create")

    current_path.should eq(spaces_path)
    has_field_with_error "space_name"
  end

  scenario "with the permalink of a disabled space" do
    disabled_space = FactoryGirl.create(:space, disabled: true)
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: "Anything"
    fill_in "space[permalink]", with: disabled_space.permalink
    fill_in "space[description]", with: "Anything"
    click_button t("_other.create")

    current_path.should eq(spaces_path)
    has_field_with_error "space_permalink"
  end

  scenario "with the permalink equal to some user's username" do
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: "Anything"
    fill_in "space[permalink]", with: user.username
    fill_in "space[description]", with: "Anything"
    click_button t("_other.create")

    current_path.should eq(spaces_path)
    has_field_with_error "space_permalink"
  end

  scenario "with the permalink equal to some disabled user's username" do
    disabled_user = FactoryGirl.create(:user, disabled: true)
    login_as(user, :scope => :user)

    visit new_space_path
    fill_in "space[name]", with: "Anything"
    fill_in "space[permalink]", with: disabled_user.username
    fill_in "space[description]", with: "Anything"
    click_button t("_other.create")

    current_path.should eq(spaces_path)
    has_field_with_error "space_permalink"
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
