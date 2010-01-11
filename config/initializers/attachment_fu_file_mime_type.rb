# AttachmentFu sets the Attachment content type from the browser sent Content-type header
#
# This monkey patch uses UNIX file utility to fix broken or missing content types headers

module Technoweenie::AttachmentFu::InstanceMethods
  def uploaded_data_with_unix_file_mime_type=(file_data)
    tmp_file = self.uploaded_data_without_unix_file_mime_type=(file_data)

    if tmp_file.present? && (unix_file = `which file`.chomp).present? && File.exists?(unix_file)
      self.content_type = `#{ unix_file } -b --mime-type #{ tmp_file.path }`.chomp
    end

    tmp_file
  end

  alias_method_chain :uploaded_data=, :unix_file_mime_type
end


