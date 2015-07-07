# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceMailer < BaseMailer

  def invitation_email(invitation_id)
    invitation = JoinRequest.find(invitation_id)
    @user = invitation.introducer
    @space = invitation.group

    locale = get_user_locale(invitation.candidate, false)
    I18n.with_locale(locale) do
      @invitation = invitation.clone
      subject = t("space_mailer.invitation_email.subject",
                  :space => @space.name, :username => @user.full_name).html_safe

      create_email(invitation.email, @user.email, subject)
    end
  end

  def processed_invitation_email(jr_id)
    jr = JoinRequest.find(jr_id)
    @candidate = jr.candidate
    @introducer = jr.introducer

    I18n.with_locale(get_user_locale(@introducer, false)) do
      @action = jr.accepted? ? t("space_mailer.processed_invitation_email.accepted") : t("space_mailer.processed_invitation_email.rejected")
      subject = t("space_mailer.processed_invitation_email.subject", :name => @candidate.name, :action => @action)
      @space = jr.group

      create_email(@introducer.email, nil, subject)
    end
  end

  def user_added_email(jr_id)
    jr = JoinRequest.find(jr_id)
    @introducer = jr.introducer
    @space = jr.group

    locale = get_user_locale(jr.candidate, false)
    I18n.with_locale(locale) do
      subject = t("space_mailer.user_added_email.subject",
                  space: @space.name, username: @introducer.full_name).html_safe
      create_email(jr.email, @introducer.email, subject)
    end
  end

  def join_request_email(jr_id, receiver_id)
    @join_request = JoinRequest.find(jr_id)
    receiver = User.find(receiver_id)
    I18n.with_locale(get_user_locale(receiver, false)) do
      subject = t("space_mailer.join_request_email.subject", :candidate => @join_request.candidate.name, :space => @join_request.group.name).html_safe

      create_email(receiver.email, @join_request.candidate.email, subject)
    end
  end

  def processed_join_request_email(jr_id)
    @join_request = JoinRequest.find(jr_id)
    user = @join_request.candidate
    to = @join_request.accepted? ? user.email : @join_request.introducer.email

    I18n.with_locale(get_user_locale(user, false)) do

      @space = @join_request.group
      @action = @join_request.accepted? ? t("space_mailer.processed_join_request_email.accepted") : t("space_mailer.processed_join_request_email.rejected")
      subject = t("space_mailer.processed_join_request_email.subject", :action => @action, :space => @space.name)

      create_email(to, nil, subject)
    end
  end

end
