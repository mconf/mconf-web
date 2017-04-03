# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module FilesizeHelper

  # Human readable file size approximating to
  # the largest unit. Assumes 0 as the size if nil
  def human_file_size(bytes=0)
    Mconf::Filesize.human_file_size(bytes)
  end

end
