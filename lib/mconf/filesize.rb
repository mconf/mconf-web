# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Filesize

    # Human readable file size approximating to
    # the largest unit. Assumes 0 as the size if nil
    def self.human_file_size(bytes=0)
      begin
        bytes = ::Filesize.from("#{bytes} B").to_i # to get an integer
        ::Filesize.from("#{bytes/1000} KB").pretty
      rescue ArgumentError
        bytes
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
