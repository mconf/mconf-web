# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Custom condition to check if a file was modified
# From: http://www.simonecarletti.com/blog/2011/02/how-to-restart-god-when-you-deploy-a-new-release/
module God
  module Conditions
    class RestartFileTouched < PollCondition
      attr_accessor :restart_file
      def initialize
        super
      end

      def process_start_time
        Time.parse(`ps -o lstart  -p #{self.watch.pid} --no-heading`)
      end

      def restart_file_modification_time
        File.exists?(self.restart_file) ? File.mtime(self.restart_file) : Time.at(0)
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'restart_file' must be specified", self) if self.restart_file.nil?
        valid
      end

      def test
        process_start_time < restart_file_modification_time
      end
    end
  end
end
