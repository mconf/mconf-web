# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

if defined?(Footnotes) && Rails.env.development?
  Footnotes.setup do |config|
    config.before do |controller, filter|
      if controller.class.name =~ /^LogoImages/
        controller.params[:footnotes] = "false" # disable footnotes
      end
    end
  end

  Footnotes.run! if ENV['FOOTNOTES']
end
