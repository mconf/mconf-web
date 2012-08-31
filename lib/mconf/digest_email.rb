# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class DigestEmail

    def self.send_daily_digest
      User.where(:receive_digest => User::RECEIVE_DIGEST_DAILY).each do |user|
        now = Time.now
        from = now - 1.day
        send_digest(user, from, now)
      end
    end

    def self.send_weekly_digest
      User.where(:receive_digest => User::RECEIVE_DIGEST_WEEKLY).each do |user|
        now = Time.now
        from = now - 7.day
        send_digest(user, from, now)
      end
    end

    def self.send_digest(to, date_start, date_end)
      posts, news, attachments, events, inbox = get_activity(to, date_start, date_end)

      unless (posts.empty? && news.empty? && attachments.empty? && events.empty? && inbox.empty?)
        Notifier.delay.digest_email(to, posts, news, attachments, events, inbox)
      end
    end

    def self.get_activity(user, date_start, date_end)
      user_spaces = user.spaces.map{ |s| s.id }

      # Recent posts in the user's spaces
      posts = Post.
        where('space_id IN (?)', user_spaces).
        where("updated_at >= ?", date_start).
        where("updated_at <= ?", date_end).
        order('updated_at desc')

      # Recent news in the user's spaces
      news = News.
        where('space_id IN (?)', user_spaces).
        where("updated_at >= ?", date_start).
        where("updated_at <= ?", date_end).
        order('updated_at desc')

      # Recent attachments in the user's spaces
      attachments = Attachment.
        where('space_id IN (?)', user_spaces).
        where("updated_at >= ?", date_start).
        where("updated_at <= ?", date_end).
        order('updated_at desc')

      # Events that started or finished in the period
      events = Event.
        where('space_id IN (?)', user_spaces).
        within(date_start, date_end).
        order('updated_at desc')

      # Unread messages in the inbox
      inbox = PrivateMessage.inbox(user).select{ |msg| !msg.checked }

      [ posts, news, attachments, events, inbox ]
    end

  end
end
