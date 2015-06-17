# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class DeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  layout 'mailers'

  def confirmation_instructions(record, token, opts={})
    opts[:subject] = "[#{Site.current.name}] #{t('devise.mailer.confirmation_instructions.subject')}"
    super
  end

  def reset_password_instructions(record, token, opts={})
    opts[:subject] = "[#{Site.current.name}] #{t('devise.mailer.reset_password_instructions.subject')}"
    super
  end
end
