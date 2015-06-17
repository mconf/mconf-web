# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module PostsHelper

  def thread(post)
    post.parent_id.nil? ? post : post.parent
  end

  def post_format( text)
   text ||= ""
   (text.include?("<") && text.include?("</") && text.include?(">")) ? text : simple_format(text)
  end

end
