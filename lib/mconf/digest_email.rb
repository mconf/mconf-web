# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class DigestEmail
    def self.send_scheduled_digest receive_digest, n
      User.where(:receive_digest => receive_digest).find_each do |user|
        now = Time.zone.now
        from = now - n.day
        send_digest(user, from, now)
      end
    end

    def self.send_daily_digest
      send_scheduled_digest User::RECEIVE_DIGEST_DAILY, 1
    end

    def self.send_weekly_digest
      send_scheduled_digest User::RECEIVE_DIGEST_WEEKLY, 7
    end

    def self.send_digest(to, date_start, date_end)
      posts, attachments, events, inbox = get_activity(to, date_start, date_end)

      unless posts.empty? && attachments.empty? && events.empty? && inbox.empty?
        ApplicationMailer.digest_email(to.id, posts, attachments, events, inbox).deliver
      end
    end

    def self.get_activity(user, date_start, date_end)
      user_spaces = user.spaces.pluck(:id)
      filter = -> (model) {
        model.where('space_id IN (?)', user_spaces).
        where("updated_at >= ?", date_start).
        where("updated_at <= ?", date_end).
        order('updated_at desc').pluck(:id)
      }

      posts = filter.call(Post)
      attachments = filter.call(Attachment)

      # Events that started or finished in the period
      if Mconf::Modules.mod_enabled?('events')
        events = Event.
          where(:owner_id => user_spaces, :owner_type => "Space").
          within(date_start, date_end).
          order('updated_at desc').pluck(:id)
      else
        events = []
      end

      [ posts, attachments, events ]
    end

  end
end
