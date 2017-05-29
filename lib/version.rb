# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  VERSION = "2.5.0".freeze

  # get the current revision from git
  @@revision = nil
  @@revision_full = false
  def self.application_revision(full=false)
    unless @@revision or @@revision_full != full
      if File.exists?("REVISION")
        @@revision = File.read("REVISION")
      else
        revision = %x[git rev-list HEAD --max-count=1]
        revision.strip!
        @@revision = revision.blank? ? "<no-ref>" : revision

        revision.slice!(6..-1) unless full
        @@revision = revision.blank? ? "<no-ref>" : revision
      end
    end
    @@revision
  end

end
