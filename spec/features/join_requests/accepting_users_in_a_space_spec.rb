# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "Accepting users in a space" do
  let(:space) { FactoryGirl.create(:space_with_associations) }
  let(:user) { FactoryGirl.create(:user) }

  context "listing all pending invitations and requests" do
    before {
      space.add_member! user, "Admin"
      login_as(user, :scope => :user)
    }

    scenario "when there are invitations and requests" do
      invite1 = FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:invite], group: space)
      invite2 = FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:invite], group: space)
      request1 = FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space)
      request2 = FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space)

      visit space_join_requests_path(space)

      check_request request1
      check_request request2
      check_invite invite1
      check_invite invite2
    end

    scenario "when there are no invitations nor requests" do
      visit space_join_requests_path(space)

      expect(page).to have_content(I18n.t('join_requests.index.no_pending_requests'))
      expect(page).to have_content(I18n.t('join_requests.index.no_pending_invitations'))
    end
  end

  context "denying a request" do
    let!(:request) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space) }

    before {
      space.add_member! user, "Admin"
      login_as(user, :scope => :user)
    }

    scenario "from the list of requests" do
      visit space_join_requests_path(space)

      click_link(I18n.t("_other.decline"), href: decline_space_join_request_path(space, request))

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.decline.declined')
      expect(page).not_to have_link(I18n.t("_other.decline"), href: decline_space_join_request_path(space, request))
   end

    scenario "from the join request's page" do
      visit space_join_request_path(space, request)
      button = page.find("a[href='#{decline_space_join_request_path(space, request)}']")
      button.click

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.decline.declined')
      expect(page).not_to have_link(I18n.t("_other.decline"), href: decline_space_join_request_path(space, request))
    end
  end

  context "accepting a request as normal user" do
    let!(:request) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space) }

    before {
      space.add_member! user, "Admin"
      login_as(user, :scope => :user)
    }

    scenario "from the list of requests" do
      visit space_join_requests_path(space)

      within(:css, "form[action='#{accept_space_join_request_path(space, request)}']") do
        click_button I18n.t('_other.accept')
      end

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.accept.accepted')
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      space.admins.should_not include(request.candidate)
    end

    scenario "from the join request's page" do
      visit space_join_request_path(space, request)

      within(:css, "form[action='#{accept_space_join_request_path(space, request)}']") do
        click_button I18n.t('join_requests.show.accept')
      end

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.accept.accepted')
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      space.admins.should_not include(request.candidate)
    end
  end

  context "accepting the request of a user and setting as admin" do
    let!(:request) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space) }

    before {
      space.add_member! user, "Admin"
      login_as(user, :scope => :user)
    }

    scenario "from the list of requests" do
      visit space_join_requests_path(space)

      within(:css, "form[action='#{accept_space_join_request_path(space, request)}']") do
        find(:css, "option[value='2']").select_option
        click_button I18n.t('_other.accept')
      end

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.accept.accepted')
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      space.admins.should include(request.candidate)
    end

    scenario "from the join request's page" do
      visit space_join_request_path(space, request)

      within(:css, "form[action='#{accept_space_join_request_path(space, request)}']") do
        find(:css, "option[value='2']").select_option
        click_button I18n.t('join_requests.show.accept')
      end

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.accept.accepted')
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      space.admins.should include(request.candidate)
    end
  end

  context "canceling an invitation" do
    let!(:invite) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:invite], group: space) }

    before {
      space.add_member! user, "Admin"
      login_as(user, :scope => :user)
    }

    scenario "from the list of requests" do
      visit space_join_requests_path(space)
      click_link(I18n.t("_other.cancel"), href: decline_space_join_request_path(space, invite))

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.decline.invitation_destroyed')
      expect(page).not_to have_link(I18n.t("_other.cancel"), href: decline_space_join_request_path(space, invite))
   end

    scenario "from the join request's page" do
      visit space_join_request_path(space, invite)
      page.click_link I18n.t('join_requests.show.cancel_invite')

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.decline.invitation_destroyed')
      expect(page).not_to have_link(I18n.t("_other.cancel"), href: decline_space_join_request_path(space, invite))
    end
  end

  context "superuser accepting a random request" do
    let(:admin) { FactoryGirl.create(:superuser) }
    let!(:request) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space) }

    before {
      login_as(admin, :scope => :user)
    }

    scenario "from the list of requests" do
      visit space_join_requests_path(space)

      within(:css, "form[action='#{accept_space_join_request_path(space, request)}']") do
        find(:css, "option[value='2']").select_option
        click_button I18n.t('_other.accept')
      end

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.accept.accepted')
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      space.admins.should include(request.candidate)
    end

    scenario "from the join request's page" do
      visit space_join_request_path(space, request)

      within(:css, "form[action='#{accept_space_join_request_path(space, request)}']") do
        find(:css, "option[value='2']").select_option
        click_button I18n.t('join_requests.show.accept')
      end

      current_path.should eq(space_join_requests_path(space))
      has_success_message I18n.t('join_requests.accept.accepted')
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      space.admins.should include(request.candidate)
    end
  end
end

def check_request(request)
  expect(page).to have_content(request.candidate.name)
  expect(page).to have_content(request.candidate.username)
  expect(page).to have_content(request.candidate.email)
  expect(page).to have_content(request.comment)

  expect(page).to have_link(I18n.t("_other.decline"), href: decline_space_join_request_path(space, request))

  expect(page).to have_css("form[action='#{accept_space_join_request_path(space, request)}'][method=post]")
  form = page.find("form[action='#{accept_space_join_request_path(space, request)}'][method=post]")
  expect(form).to have_css("input[type=submit]")
  expect(form).to have_select("join_request_role_id", options: ["Administrator", "User"], selected: "User")
end

def check_invite(invite)
  expect(page).to have_content(invite.candidate.name)
  expect(page).to have_content(invite.candidate.username)
  expect(page).to have_content(invite.candidate.email)
  expect(page).to have_content(invite.comment)
  expect(page).to have_content(invite.role)
  expect(page).to have_link(I18n.t("_other.cancel"), href: decline_space_join_request_path(space, invite))
end
