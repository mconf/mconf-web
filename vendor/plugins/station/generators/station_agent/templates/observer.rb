class <%= class_name %>Observer < ActiveRecord::Observer
  def after_create(<%= file_name %>)
    <%= class_name %>Mailer.deliver_signup_notification(<%= file_name %>)
  end

  def after_save(<%= file_name %>)
    if <%= file_name %>.class.password_recovery?
      <%= class_name %>Mailer.deliver_lost_password(<%= file_name %>) if <%= file_name %>.recently_lost_password?
      <%= class_name %>Mailer.deliver_reset_password(<%= file_name %>) if <%= file_name %>.recently_reset_password?
    end

    if <%= file_name %>.class.agent_options[:activation]
      <%= class_name %>Mailer.deliver_activation(<%= file_name %>) if <%= file_name %>.recently_activated?
    end
  end
end
