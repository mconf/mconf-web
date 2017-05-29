# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Invitation < ActiveRecord::Base
  include Mconf::LocaleControllerModule

  belongs_to :target, :polymorphic => true
  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  before_validation :set_end_from_duration

  DURATION =
    {
      '5m':   5*60,
     '10m':   10*60,
     '15m':   15*60,
     '20m':   20*60,
     '30m':   30*60,
     '45m':   45*60,
     '1h':    60*60,
     '1h30m': 90*60,
     '2h':    2*60*60,
     '3h':    3*60*60,
     '4h':    4*60*60,
     '5h':    5*60*60,
     '6h':    6*60*60,
     '12h':   12*60*60
    }.freeze

  def self.duration_i18n(locale)
    DURATION.map{ |k, v|
      [I18n.t("activerecord.attributes.invitation.duration_values.#{k}", locale: locale), v]
    }.to_h
  end

  def self.create_invitations(user_list, params)
    params = params.clone

    # creates an invitation for each user
    users = user_list.try(:split, ",") || []
    users.map! { |u| u.strip }

    users.map do |user_str|
      user = User.find_by(id: user_str)
      if user
        params[:recipient] = user
        params[:recipient_email] = nil
      else
        params[:recipient] = nil
        params[:recipient_email] = user_str
      end
      self.create(params)
    end
  end

  # Builds a flash message containing all the names of invited users
  def self.build_flash(list, message)
    msg = message + " "
    msg += list.map { |user|
      user.is_a?(User) ? ActionController::Base.helpers.strip_tags(user.full_name) : user
    }.join(", ")
  end

  # Checks if the invitations in `invitations` are valid or will fail when sent.
  # Returns two arrays:
  #   [0] The Users and/or emails that received the invitation successfully
  #   [1] The Users and/or emails that did not receive the invitation
  def self.check_invitations(invitations)
    success = []
    error = []

    # the invitation will only be invalid if the user or their email is invalid
    for invitation in invitations
      if invitation.recipient.nil?
        mail = invitation.recipient_email
        if ValidateEmail.valid?(mail)
          success << mail
        else
          error << mail
        end
      else
        user = invitation.recipient
        if ValidateEmail.valid?(user.email)
          success << user
        else
          error << user
        end
      end
    end

    return success, error
  end

  # Sends the invitation to the recipient.
  # Respects the preferences of the user, sending the notification
  # (usually via email).
  # Uses the mailer variable to build the correct emails.
  def send_invitation
    mailer = if self.is_a? WebConferenceInvitation
               WebConferenceMailer
             elsif self.is_a? EventInvitation
               EventMailer
             else
               nil
             end
    return false if mailer.nil?

    mailer.invitation_email(self.id).deliver
    true
  end

  def to_ical
    if self.is_a? EventInvitation
      target.to_ical
    else
      event = Icalendar::Event.new

      attendee_list = WebConferenceInvitation
                        .where(invitation_group: self.invitation_group)
                        .includes(:recipient)
                        .pluck(:email, :recipient_email)
                        .flatten.compact.uniq

      # We send the dates always in UTC to make it easier. The 'Z' in the ends denotes
      # that it's in UTC.
      event.dtstart = self.starts_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ") unless self.starts_on.blank?
      event.dtend = self.ends_on.in_time_zone('UTC').strftime("%Y%m%dT%H%M%SZ") unless self.ends_on.blank?
      event.organizer = sender.email
      event.attendee = attendee_list.flatten.compact unless self.invitation_group.blank?
      event.ip_class = "PUBLIC"
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

  # Get a https/http URL depending on the setting on the site
  def url_with_protocol
    begin
      u = URI.parse(self.url)
      u.scheme = Site.current.ssl? ? 'https' : 'http'
      u.to_s
    rescue URI::InvalidURIError
      url
    end
  end

  def set_end_from_duration
    if self.ends_on.blank? && self.has_duration? && !self.starts_on.blank?
      self.ends_on = self.starts_on + self.duration.seconds
    end
  end

  def has_duration?
    !self.duration.blank? && self.duration > 0
  end
end
