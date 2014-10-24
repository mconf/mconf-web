# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'exception_notification/rails'

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'exception_notification/resque'

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, ExceptionNotification::Resque]
Resque::Failure.backend = Resque::Failure::Multiple

def check_conditions
  if !Rails.application.config.consider_all_requests_local && Site.table_exists?
    site = Site.current
    return site &&
      site.respond_to?(:exception_notifications) &&
      site.exception_notifications
  else
    false
  end
end

def get_sender_address
  site = Site.current
  if site.respond_to?(:name) && site.respond_to?(:smtp_sender)
    %("#{site.name}" <#{site.smtp_sender}>)
  else
    "Undefined"
  end
end

def get_receivers
  site = Site.current

  # accepts " ", "," and ";" as separators
  if !site.respond_to?(:exception_notifications) || site.exception_notifications_email.blank?
    recvs = []
  else
    recvs = site.exception_notifications_email.split(/[\s,;]/).reject(&:empty?)
  end
end

def get_prefix
  site = Site.current
  if !site.respond_to?(:exception_notifications_prefix) ||  site.exception_notifications_prefix.blank?
    "[ERROR] "
  else
    site.exception_notifications_prefix + " "
  end
end

if check_conditions

  ExceptionNotification.configure do |config|
    # Ignore additional exception types.
    # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
    # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

    # Adds a condition to decide when an exception must be ignored or not.
    # The ignore_if method can be invoked multiple times to add extra conditions.
    # config.ignore_if do |exception, options|
    #   not Rails.env.production?
    # end

    # Notifiers =================================================================

    # Email notifier sends notifications by email.
    config.add_notifier :email, {
      :email_prefix         => get_prefix,
      :sender_address       => get_sender_address,
      :exception_recipients => get_receivers
    }

    # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
    # config.add_notifier :campfire, {
    #   :subdomain => 'my_subdomain',
    #   :token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
    # config.add_notifier :hipchat, {
    #   :api_token => 'my_token',
    #   :room_name => 'my_room'
    # }

    # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
    # config.add_notifier :webhook, {
    #   :url => 'http://example.com:5555/hubot/path',
    #   :http_method => :post
    # }

  end
end
