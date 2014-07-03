# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'valid_email'

module Mconf

  # A helper class to deal with invitations to web conferences
  class Invitation
    include Mconf::LocaleControllerModule

    attr_accessor :title
    attr_accessor :description
    attr_accessor :starts_on
    attr_accessor :ends_on
    attr_accessor :url
    attr_accessor :room
    attr_accessor :from

    def to_ical
      event = Icalendar::Event.new
      # We send the dates always in UTC to make it easier. The 'Z' in the ends denotes
      # that it's in UTC.
      event.dtstart = @starts_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ")
      event.dtend = @ends_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ")
      event.organizer = @from.email
      event.klass = "PUBLIC"
      event.uid = @url
      event.url = @url
      event.location = @url
      event.description = @description
      event.summary = @title

      cal = Icalendar::Calendar.new
      cal.add_event(event)
      cal.to_ical
    end

    # Sends the invitation to a user or email.
    # Respects the preferences of the user, sending the notification either via
    # email or private message.
    def send(user)
      # note: for emails, for now, we always assume it succeeded
      result = true

      if user.is_a?(User)
        if user.notify_via_email?
          WebConferenceMailer.invitation_mail(self, user.email).deliver
        end
        if user.notify_via_private_message?
          result = send_private_message(user)
        end

      # assumes `user` is a string with an email
      else
        WebConferenceMailer.invitation_mail(self, user).deliver
      end

      result
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
          if invitation.send(user)
            success << user
          else
            error << user
          end
        else
          if ValidateEmail.valid?(user)
            if invitation.send(user)
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
end
