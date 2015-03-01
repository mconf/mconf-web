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
