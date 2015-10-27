# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Filesize

    # Human readable file size approximating to
    # the largest unit. Assumes 0 as the size if nil
    def self.human_file_size(bytes=nil)
      if bytes.blank?
        nil
      else
        begin
          bytes = ::Filesize.from("#{bytes} B").to_i # to get an integer
          ::Filesize.from("#{bytes/1000} KB").pretty
        rescue ArgumentError
          bytes
        end
      end
    end

    # Converts a value to a file size in bytes. Will try to interpret the value
    # the best as possible. Understands values such as "15 MB", "5 kiB", "1000",
    # 35000, etc.
    # Returns 0 if the value is empty (e.g. blank string) or nil if it's invalid.
    def self.convert(value)
      if value.blank?
        nil
      elsif Mconf::Filesize.is_number?(value)
        begin
          # express size in bytes if a number without units was present
          ::Filesize.from("#{value} B").to_i
        rescue ArgumentError
          nil
        end
      elsif Mconf::Filesize.is_filesize?(value)
        begin
          ::Filesize.from(value).to_i
        rescue ArgumentError
          nil
        end
      else
        nil
      end
    end

    def self.is_number? n
      begin
        Float(n)
        true
      rescue
        false
      end
    end

    def self.is_filesize? n
      ::Filesize.parse(n)[:type].present?
    end
  end
end
