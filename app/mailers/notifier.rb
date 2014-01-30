# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

#This class will compose all the mails that the application should send
class Notifier < ActionMailer::Base

  def invitation_email(invitation)

    setup_email(invitation.email)

    @user = invitation.introducer
    @space = Space.find(invitation.group_id)

    @subject += I18n.t("invitation.to_space",
      :space => @space.name,
      :username => invitation.introducer.full_name,
      :locale => @user.locale).html_safe

    @invitation = invitation

    if invitation.candidate
      @name = invitation.candidate.full_name
    else
      @name = invitation.email[0,invitation.email.index('@')]
    end
    @replyto = invitation.introducer.email

    create_default_mail(get_locale_from_user(@user))
  end

  def event_invitation_email(invitation)
    setup_email(invitation[:receiver])

    @sender = invitation[:sender]
    @locale = get_locale_from_user(invitation[:user])
    @event = invitation[:event]
    @replyto = invitation[:sender].email
    @subject = t('event.invite_title', :username => @sender.full_name, :eventname => @event.name, :space => @event.space.name, :locale => @locale).html_safe

    create_default_mail(@locale)
  end

  def event_notification_email(notification)
    setup_email(notification[:receiver].email)

    @event = notification[:event]
    @sender = notification[:sender]
    @subject = t('event.notification_title', :username => @sender.full_name, :eventname => @event.name, :space => @event.space.name).html_safe
    @receiver = notification[:receiver]
    @replyto = @sender.email

    create_default_mail(get_locale_from_user(@receiver))
  end

  def permission_update_notification_email(sender,receiver,stage,rol)
    setup_email(receiver.email)

    if stage.type.name == 'Space'
      @subject += I18n.t("permission.notification.subject.space", :username=>sender.full_name , :space=>stage.name, :locale=>receiver.locale).html_safe
      @text = I18n.t("permission.notification.space", :username=>sender.full_name , :space=>stage.name , :role => rol, :locale=>receiver.locale ).html_safe;
    elsif stage.type.name == 'Event'
      @subject += I18n.t("permission.notification.subject.event", :username=>sender.full_name , :event=>stage.name, :locale=>receiver.locale).html_safe
      @text = I18n.t("permission.notification.event", :username=>sender.full_name , :event=>stage.name , :role => rol, :locale=>receiver.locale).html_safe;
    else
      @subject += I18n.t("permission.notification.subject.default", :username=>sender.full_name , :stage=>stage.name, :locale=>receiver.locale).html_safe
      @text = I18n.t("permission.notification.default", :locale=>receiver.locale).html_safe;
    end
    @sender = sender
    @receiver = receiver
    @replyto = sender.email

    create_default_mail(get_locale_from_user(receiver))
  end

  def processed_invitation_email(invitation, receiver)
    setup_email(receiver.email)

    action = invitation.accepted? ? I18n.t("invitation.yes_accepted", :locale=>receiver.locale) : I18n.t("invitation.not_accepted", :locale=>receiver.locale).html_safe
    if invitation.candidate != nil
      @subject += I18n.t("email.invitation_result.admin_side",:name=>invitation.candidate.name, :action => action, :spacename =>invitation.group.name, :locale=>receiver.locale).html_safe
    else
      @subject += I18n.t("email.invitation_result.admin_side",:name=>invitation.email, :action => action, :spacename =>invitation.group.name, :locale=>receiver.locale).html_safe
    end
    @invitation = invitation
    @space = invitation.group
    @signature  = Site.current.signature_in_html
    @action = action
    @replyto = invitation.email
    @locale = get_locale_from_user(receiver)

    create_default_mail(get_locale_from_user(receiver))
  end

  def join_request_email(jr,receiver)
    setup_email(receiver.email)

    @subject += I18n.t("join_requests.ask_subject", :candidate => jr.candidate.name, :space => jr.group.name, :locale=>receiver.locale)
    @join_request = jr
    @signature  = Site.current.signature_in_html
    @replyto = jr.candidate.email

    create_default_mail(get_locale_from_user(receiver))
  end

  def processed_join_request_email(jr)
    setup_email(jr.candidate.email)

    action = jr.accepted? ? I18n.t("invitation.yes_accepted",:locale=>jr.candidate.locale) : I18n.t("invitation.not_accepted",:locale=>jr.candidate.locale).html_safe
    @subject += I18n.t("email.invitation_result.user_side", :action => action, :spacename =>jr.group.name,:locale=>jr.candidate.locale).html_safe
    @jr = jr
    @space = jr.group
    @action = action

    create_default_mail(get_locale_from_user(jr.candidate))
  end

  #This is used when an user registers in the application, in order to confirm his registration
  def confirmation_email(user)
    setup_email(user.email)

    @subject += I18n.t("email.welcome",:sitename=>Site.current.name,:locale=>user.locale).html_safe
    @name = user.full_name
    @hash = user.activation_code
    @contact_email = Site.current.smtp_sender
    @signature  = Site.current.signature_in_html

    create_default_mail(get_locale_from_user(user))
  end

  def activation(user)
    setup_email(user.email)

    @subject += I18n.t("account_activated", :sitename=>Site.current.name).html_safe
    @user = user
    @contact_email = Site.current.smtp_sender
    @url  = "http://" + Site.current.domain + "/"
    @sitename  = Site.current.name
    @signature  = Site.current.signature_in_html

    create_default_mail(get_locale_from_user(user))
  end

  #This is used when a user asks for his password.
  def lost_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.request", :sitename=>Site.current.name,:locale=>user.locale).html_safe
    @name = user.full_name
    @contact_email = Site.current.smtp_sender
    @url  = "http://#{Site.current.domain}/reset_password/#{user.reset_password_code}"
    @signature  = Site.current.signature_in_html

    create_default_mail(get_locale_from_user(user))
  end

  #this method is used when a user has asked for his old password, and then he resets it.
  def reset_password(user)
    setup_email(user.email)

    @subject += I18n.t("password.reset_email", :sitename=>Site.current.name,:locale=>user.locale).html_safe
    @sitename  = Site.current.name
    @signature = Site.current.signature_in_html

    create_default_mail(get_locale_from_user(user))
  end

  #this method is used when a user has sent feedback to the admin.
  def feedback_email(email, subject, body)
    setup_email(Site.current.smtp_sender)

    @subject += I18n.t("feedback.one").html_safe + " " + subject
    @text = body
    @user = email
    @replyto = email

    create_default_mail(I18n.default_locale)
  end

  def webconference_invite_email(params)
    setup_email(params[:email_receiver])

    I18n.with_locale(params[:locale]) do
      @sender = params[:user_name]
      @room_name = params[:room_name]
      @room_url = params[:room_url]
      @mobile_url = params[:mobile_url]
      @subject = t('invite.title')
      @message = params[:body]
      @signature  = Site.current.signature_in_html
      @replyto = params[:email_sender]
    end

    create_default_mail(params[:locale])
  end

  def digest_email(receiver,posts,news,attachments,events,inbox)
    setup_email(receiver.email)

    @posts = posts
    @news = news
    @attachments = attachments
    @events = events
    @inbox = inbox
    @locale = receiver.locale
    if receiver.receive_digest == User::RECEIVE_DIGEST_DAILY
      @type = t('email.digest.type.daily', :locale => @locale)
    else
      @type = t('email.digest.type.weekly', :locale => @locale)
    end
    @subject = t('email.digest.title', :type => @type, :locale => @locale)
    @signature  = Site.current.signature_in_html

    create_default_mail(get_locale_from_user(receiver))
  end

  private

  def setup_email(recipients)
    @recipients = recipients
    @from = "#{ Site.current.name } <#{ Site.current.smtp_sender }>"
    @replyto = @from
    @subject = I18n.t("vcc_mail_label").html_safe + " "
    @content_type ="text/html"
  end

  def create_default_mail(locale)
    I18n.with_locale(locale) do
      mail(:to => @recipients, :subject => @subject, :from => @from, :headers => @headers, :reply_to => @replyto)
    end
  end

  # TODO: method also defined in LocaleControllerModule, should be moved to a common file/class
  def get_locale_from_user(user)

    # user locale
    if not user.nil? and user.is_a?(User) and
        user.locale.present? and is_locale_available?(user.locale)
      user.locale.to_sym

    # site locale
    elsif Site.current and Site.current.locale and is_locale_available?(Site.current.locale)
      Site.current.locale.to_sym

    # default locale - last fallback
    else
      I18n.default_locale
    end
  end

  # TODO: method also defined in LocaleControllerModule, should be moved to a common file/class
  def is_locale_available?(locale)
    configatron.i18n.default_locales.include?(locale.to_sym)
  end

end
