# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# AttachmentFu sets the Attachment content type from the browser sent Content-type header
#
# This monkey patch uses UNIX file utility to fix broken or missing content types headers

module Technoweenie::AttachmentFu::InstanceMethods
  def uploaded_data_with_unix_file_mime_type=(file_data)
    tmp_file = self.uploaded_data_without_unix_file_mime_type=(file_data)

    if tmp_file.present? && (unix_file = `which file`.chomp).present? && File.exists?(unix_file)
      `#{ unix_file } -v 2>&1` =~ /^file-(.*)$/
      version = $1

      self.content_type = if version >= "4.24"
                            `#{ unix_file } -b --mime-type #{ tmp_file.path }`.chomp
                          else
                            `#{ unix_file } -bi #{ tmp_file.path }`.chomp =~ /(\w*\/[\w+-\.]*)/
                            $1
                          end
    end

    tmp_file
  end

  alias_method_chain :uploaded_data=, :unix_file_mime_type
end


