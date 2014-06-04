# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SpaceMailer < ApplicationMailer

  def invitation_email(invitation_id)
    invitation = JoinRequest.find(invitation_id)
    @user = invitation.introducer
    @space = Space.find(invitation.group_id)

    I18n.with_locale(get_user_locale(@user, false)) do
      @invitation = invitation.clone
      subject = t("invitation.to_space",
        :space => @space.name,
        :username => @user.full_name).html_safe

      create_email(invitation.email, @user.email, subject)
    end
  end

  def processed_invitation_email(invitation, receiver)
    I18n.with_locale(get_user_locale(receiver, false)) do
      action = invitation.accepted? ? t("invitation.yes_accepted", :locale=>receiver.locale) : I18n.t("invitation.not_accepted").html_safe
      @subject = "[Cocozilda] "
      if invitation.candidate != nil
        @subject += t("email.invitation_result.admin_side",:name => invitation.candidate.name, :action => action, :spacename => invitation.group.name).html_safe
      else
        @subject += t("email.invitation_result.admin_side",:name => invitation.email, :action => action, :spacename => invitation.group.name).html_safe
      end
      @invitation = invitation
      @space = invitation.group
      @signature  = Site.current.signature_in_html
      @action = action

      create_email(receiver.email, invitation.email, @subject)
    end
  end

  def join_request_email(jr_id, receiver_id)
    jr = JoinRequest.find(jr_id)
    receiver = User.find(receiver_id)
    I18n.with_locale(get_user_locale(receiver, false)) do
      subject = t("space_mailer.join_request_email.subject", :candidate => jr.candidate.name, :space => jr.group.name).html_safe
      @join_request = jr

      create_email(receiver.email, jr.candidate.email, subject)
    end
  end

  def processed_join_request_email(jr_id)
    jr = JoinRequest.find(jr_id)
    user = jr.candidate
    I18n.with_locale(get_user_locale(user, false)) do

      action = jr.accepted? ? t("space_mailer.processed_join_request_email.accepted") : t("space_mailer.processed_join_request_email.rejected")
      subject = t("space_mailer.processed_join_request_email.subject", :action => action, :space => jr.group.name)
      @join_request = jr

      create_email(user.email,nil,subject)
    end
  end

end
