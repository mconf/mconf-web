# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Invitation < ActiveRecord::Base
  include Mconf::LocaleControllerModule

  belongs_to :target, :polymorphic => true
  belongs_to :from, :class_name => "User"

  attr_accessible :from, :target, :starts_on, :ends_on, :title, :url, :description, :type

  # Sends the invitation to a user or email.
  # Respects the preferences of the user, sending the notification either via
  # email or private message.
  # Uses the mailer variable to build the correct emails
  def send_email(user)
    mailer = if self.is_a? WebConferenceInvitation
               WebConferenceMailer
             elsif self.is_a? EventInvitation
               EventMailer
             else
               nil
             end
    return false if mailer.nil?

    # note: for emails, for now, we always assume it succeeded
    result = true

    if user.is_a?(User)
      if user.notify_via_email?
        mailer.invitation_mail(self.id, user.id).deliver
      end
      if user.notify_via_private_message?
        result = send_private_message(user)
      end

    # assumes `user` is a string with an email
    else
      mailer.invitation_mail(self.id, user).deliver
    end

    result
  end

  # Receives a string with user_ids and emails and returns and array of them
  def self.split_invitation_senders(email_string)
    users = email_string.split(",")
    users.map { |user_str|
      user = User.find_by_id(user_str)
      user ? user : user_str
    }
  end

  # Builds a flash message containing all the names of invited users
  def self.build_flash(list, message)
    msg = message + " "
    msg += list.map { |user|
      user.is_a?(User) ? user.full_name : user
    }.join(", ")
    msg
  end

  # Sends an invitation in `invitation` to all the Users or emails in the
  # array `users`.
  # Returns two arrays:
  #   [0] The Users and/or emails that received the invitation successfully
  #   [1] The Users and/or emails that did not receive the invitation
  def self.send_batch(invitation, users)
    success = []
    error = []

    for user in users
      if user.is_a?(User)
        if invitation.send_email(user)
          success << user
        else
          error << user
        end
      else
        if ValidateEmail.valid?(user)
          if invitation.send_email(user)
            success << user
          else
            error << user
          end
        else
          error << user
        end
      end
    end

    return success, error
  end

  def to_ical
    if self.is_a? EventInvitation
      event.to_ics.to_ical
    else
      event = Icalendar::Event.new

      # We send the dates always in UTC to make it easier. The 'Z' in the ends denotes
      # that it's in UTC.
      event.dtstart = self.starts_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ") unless self.starts_on.blank?
      event.dtend = self.ends_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ") unless self.ends_on.blank?
      event.organizer = from.email
      event.klass = "PUBLIC"
      event.uid = self.url
      event.url = self.url
      event.location = self.url
      event.description = self.description
      event.summary = self.title

      cal = Icalendar::Calendar.new
      cal.add_event(event)
      cal.to_ical
    end
  end

  private

  # TODO: this could be used for other messages, not only webconf invitations, could be
  #   moved somewhere else
  # TODO: not sure if here is the best place for this, maybe it should be done asynchronously
  #   together with emails, maybe in a class that abstracts "notifications" in general
  def send_private_message(user)
    I18n.with_locale(get_user_locale(user, false)) do
      content = ActionView::Base.new(Rails.configuration.paths["app/views"])
        .render(:partial => 'web_conference_mailer/invitation_mail',
                :format => :pm,
                :locals => { :invitation => self })
      opts = {
        :sender_id => self.from.id,
        :receiver_id => user.id,
        :body => content,
        :title => I18n.t('web_conference_mailer.invitation_mail.subject', :name => self.from.full_name)
      }
      private_message = PrivateMessage.new(opts)
      private_message.save
    end
  end

end
