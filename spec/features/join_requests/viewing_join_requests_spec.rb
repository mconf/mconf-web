# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'
require 'support/feature_helpers'

feature "Viewing join requests" do
  let(:space) { FactoryGirl.create(:space_with_associations) }
  let(:user) { FactoryGirl.create(:user) }

  let!(:request) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:request], group: space) }
  let!(:invite) { FactoryGirl.create(:space_join_request, request_type: JoinRequest::TYPES[:invite], group: space) }

  context "a normal user" do
    before {
      login_as(user, :scope => :user)
    }

    scenario "viewing a request he created" do
      request.update_attributes(candidate: user)
      visit space_join_request_path(space, request)

      expect(page).not_to have_selector("a[href='#{accept_space_join_request_path(space, request)}']")
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, request)}']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, request)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_candidate.title_request',
                    space: space.name, date: I18n.l(request.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_candidate.comment_request')
      expect(page).to have_content(text)
    end

    scenario "viewing an invitation he received" do
      invite.update_attributes(candidate: user)
      visit space_join_request_path(space, invite)

      accept = page.find("a[href='#{accept_space_join_request_path(space, invite)}']")
      accept[:'data-method'].should eql("post")
      expect(page).not_to have_selector("[name='join_request[role_id]']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, invite)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(invite.comment)

      text = I18n.t('join_requests.show.is_candidate.title_invitation', introducer: invite.introducer.full_name,
                    space: space.name, date: I18n.l(request.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_candidate.comment_invitation', name: invite.introducer.full_name)
      expect(page).to have_content(text)
    end

    scenario "viewing a request from another user" do
      visit space_join_request_path(space, request)
      should_be_403_page
    end

    scenario "trying to view join request index" do
      visit space_join_requests_path(space)
      should_be_403_page
    end

    scenario "trying to invite people to a space" do
      visit invite_space_join_requests_path(space)
      should_be_403_page
    end
  end

  context "a space admin" do
    before {
      space.add_member! user, "Admin"
      login_as(user, :scope => :user)
    }

    scenario "viewing a request to his space" do
      visit space_join_request_path(space, request)

      form = page.find("form[action='#{accept_space_join_request_path(space, request)}'][method=post]")
      expect(form).to have_css("input[type=submit]")
      expect(form).to have_select("join_request_role_id", options: ["Administrator", "User"], selected: "User")

      decline = page.find("a[href='#{decline_space_join_request_path(space, request)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_other.title_request', candidate: request.candidate.full_name,
                    space: space.name, date: I18n.l(request.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_other.comment_request', name: request.candidate.full_name)
      expect(page).to have_content(text)
    end

    scenario "viewing an invitation another user made to his space" do
      visit space_join_request_path(space, invite)

      expect(page).not_to have_selector("a[href='#{accept_space_join_request_path(space, invite)}']")
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, invite)}']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, invite)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_other.title_invitation', introducer: invite.introducer.full_name,
                    candidate: invite.candidate.full_name, space: space.name,
                    date: I18n.l(invite.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_candidate.comment_invitation', name: invite.introducer.full_name)
      expect(page).to have_content(text)
    end

    scenario "viewing an invitation he made to his space" do
      invite.update_attributes(introducer: user)
      visit space_join_request_path(space, invite)

      expect(page).not_to have_selector("a[href='#{accept_space_join_request_path(space, invite)}']")
      expect(page).not_to have_selector("form[action='#{accept_space_join_request_path(space, invite)}']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, invite)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_introducer.title_invitation', candidate: invite.candidate.full_name,
                    space: space.name, date: I18n.l(invite.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_introducer.comment_invitation')
      expect(page).to have_content(text)
    end
  end

  context "a superuser" do
    let(:admin) { FactoryGirl.create(:superuser) }
    before {
      login_as(admin, :scope => :user)
    }

    scenario "viewing an invitation he received" do
      invite.update_attributes(candidate: admin)
      visit space_join_request_path(space, invite)

      accept = page.find("a[href='#{accept_space_join_request_path(space, invite)}']")
      accept[:'data-method'].should eql("post")
      expect(page).not_to have_selector("[name='join_request[role_id]']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, invite)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(invite.comment)

      text = I18n.t('join_requests.show.is_candidate.title_invitation', introducer: invite.introducer.full_name,
                    space: space.name, date: I18n.l(request.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_candidate.comment_invitation', name: invite.introducer.full_name)
      expect(page).to have_content(text)
    end

    scenario "viewing an invitation he sent" do
      invite.update_attributes(introducer: admin)
      visit space_join_request_path(space, invite)

      expect(page).not_to have_selector("a[href='#{accept_space_join_request_path(space, invite)}']")
      expect(page).not_to have_selector("[name='join_request[role_id]']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, invite)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_introducer.title_invitation', candidate: invite.candidate.full_name,
                    space: space.name, date: I18n.l(invite.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_introducer.comment_invitation')
      expect(page).to have_content(text)
    end

    scenario "viewing a request he made" do
      request.update_attributes(candidate: admin)
      visit space_join_request_path(space, request)

      expect(page).not_to have_selector("[name='join_request[role_id]']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, request)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_candidate.title_request',
                    space: space.name, date: I18n.l(request.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_candidate.comment_request')
      expect(page).to have_content(text)
    end

    scenario "viewing a request he has no relationship with" do
      visit space_join_request_path(space, request)

      form = page.find("form[action='#{accept_space_join_request_path(space, request)}'][method=post]")
      expect(form).to have_css("input[type=submit]")
      expect(form).to have_select("join_request_role_id", options: ["Administrator", "User"], selected: "User")

      decline = page.find("a[href='#{decline_space_join_request_path(space, request)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(request.comment)

      text = I18n.t('join_requests.show.is_other.title_request', candidate: request.candidate.full_name,
                    space: space.name, date: I18n.l(request.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_other.comment_request', name: request.candidate.full_name)
      expect(page).to have_content(text)
    end

    scenario "viewing an invitation he has no relationship with" do
      visit space_join_request_path(space, invite)

      expect(page).not_to have_selector("a[href='#{accept_space_join_request_path(space, invite)}']")
      expect(page).not_to have_selector("[name='join_request[role_id]']")

      decline = page.find("a[href='#{decline_space_join_request_path(space, invite)}']")
      decline[:'data-method'].should eql("post")
      decline[:'data-confirm'].should_not be_blank

      expect(page).to have_content(invite.comment)

      text = I18n.t('join_requests.show.is_other.title_invitation', candidate: invite.candidate.full_name,
                    introducer: invite.introducer.full_name, space: space.name,
                    date: I18n.l(invite.created_at.to_date, :format => :long))
      expect(page).to have_content(text)
      text = I18n.t('join_requests.show.is_candidate.comment_invitation', name: invite.introducer.full_name)
      expect(page).to have_content(text)
    end
  end

  context "an anonymous user" do
    scenario "trying to view a request" do
      visit space_join_request_path(space, request)

      current_path.should eq(login_path)
    end

    scenario "trying to view an invitation" do
      visit space_join_request_path(space, invite)

      current_path.should eq(login_path)
    end

    scenario "trying to index join requests" do
      visit space_join_requests_path(space)

      current_path.should eq(login_path)
      end

    scenario "trying to invite users to a space" do
      visit invite_space_join_requests_path(space)

      current_path.should eq(login_path)
    end
  end
end
