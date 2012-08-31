# -*- coding: utf-8 -*-
namespace :license do
  LICENSE_HEADER = <<-EOS
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

  EOS

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

        enc = encoding_line(content)
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
