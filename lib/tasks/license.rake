# -*- coding: utf-8 -*-
namespace :license do
  LICENSE_HEADER = <<-EOS
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

  EOS

#   LICENSE_HEADER = <<-EOS
# # Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
# #
# # This file is part of VCC (Virtual Conference Center).
# #
# # VCC is free software: you can redistribute it and/or modify
# # it under the terms of the GNU Affero General Public License as published by
# # the Free Software Foundation, either version 3 of the License, or
# # (at your option) any later version.
# #
# # VCC is distributed in the hope that it will be useful,
# # but WITHOUT ANY WARRANTY; without even the implied warranty of
# # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# # GNU Affero General Public License for more details.
# #
# # You should have received a copy of the GNU Affero General Public License
# # along with VCC.  If not, see <http://www.gnu.org/licenses/>.

#   EOS

  LICENSE_DIRS = %w( app spec lib config )

  def files_for_dir(dir)
    Dir[File.join(Rails.root.to_s, dir, '**', '*.rb')]
  end

  def encoding_line(content)
    r = content.match(/# -\*- coding:.*-\*-\n/)
    r ? r[0] : ""
  end

  desc "Add the license header to all files"
  task :add do
    LICENSE_DIRS.each do |dir|
      files_for_dir(dir).each do |file|
        content = File.new(file, 'r').read
        next if content.include?(LICENSE_HEADER)

        enc = encondig_line(content)
        content.gsub!(enc, "") unless enc.empty?
        File.new(file, 'w').write(enc + LICENSE_HEADER + content)
        puts file
      end
    end
  end

   desc "Remove the license header from all files"
   task :remove do
    LICENSE_DIRS.each do |dir|
      files_for_dir(dir).each do |file|
        content = File.new(file, 'r').read
        File.new(file, 'w').write(content.gsub(LICENSE_HEADER, ""))
        puts file
      end
    end
  end
end
