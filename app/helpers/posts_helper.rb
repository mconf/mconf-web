# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module PostsHelper

  def first_words(text, size)
    truncate(text, :length => size)
  end

  def thread(post)
    post.parent_id.nil? ? post : post.parent
  end

  def post_format( text)
   text ||=""
   (text.include?("<") && text.include?("</") && text.include?(">")) ? text : simple_format(text)
  end

  def get_today_posts(posts)
    posts.select{|x| x.updated_at > Date.yesterday}
  end

  def get_yesterday_posts(posts)
    posts.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}
  end

  def get_last_week_posts(posts)
    posts.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}
  end

  def get_older_posts(posts)
    posts.select{|x| x.updated_at < Date.today - 7}
  end

  #method to know if a thread or any of its comments has attachment/s
  def has_attachments(thread)
    if thread.attachments.any?
      return true
    end
    #let's look around the children
    for post in thread.children
      if post.attachments.any?
        return true
      end
    end
    return false
  end

  #method to get the attachment name
  def attachment_name(thread)
    if thread.attachments.any?
      return thread.attachments.first.filename
    end
    #let's look around the children
    for post in thread.children
      if post.attachments.any?
        return post.attachments.first.filename
      end
    end
    return ""
  end
end
