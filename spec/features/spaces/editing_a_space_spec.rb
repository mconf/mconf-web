# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"
require "support/feature_helpers"

feature "Editing a space" do
  let!(:admin) { FactoryGirl.create(:user, superuser: true) }
  let!(:space) { FactoryGirl.create(:space) }

  skip "using the name of another existing space" do
    # page is showing the error as a notification instead of beside the input
    # as simple_form does by default

    another_space = FactoryGirl.create(:space)
    login_as(admin, :scope => :user)

    visit edit_space_path(space)
    fill_in "space[name]", with: another_space.name
    click_button t("_other.save")

    current_path.should eq(space_path(space))
    has_field_with_error "space_name"
  end

  skip "using the name of another disabled space" do
    # page is showing the error as a notification instead of beside the input
    # as simple_form does by default

    disabled_space = FactoryGirl.create(:space, disabled: true)
    login_as(admin, :scope => :user)

    visit edit_space_path(space)
    fill_in "space[name]", with: disabled_space.name
    click_button t("_other.save")

    current_path.should eq(space_path(space))
    has_field_with_error "space_name"
  end

end
