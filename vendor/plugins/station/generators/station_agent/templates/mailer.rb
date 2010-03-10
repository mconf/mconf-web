class <%= class_name %>Mailer < ActionMailer::Base
  def signup_notification(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += I18n.t(:please_activate_account)
  <% if options[:include_activation] %>
    @body[:url]  = "http://#{ Site.current.domain }/activate/#{<%= file_name %>.activation_code}"
  <% else %>
    @body[:url]  = "http://#{ Site.current.domain}/login/"
  <% end %>
  end
  
  def activation(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += I18n.t(:account_activated)
    @body[:url]  = "http://#{ Site.current.domain }/"
  end

  def lost_password(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += I18n.t(:request_change_password)
    @body[:url]  = "http://#{ Site.current.domain }/reset_password/#{ <%= file_name %>.reset_password_code }"
  end

  def reset_password(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += I18n.t(:password_has_been_reset)
    @body[:url]  = "http://#{ Site.current.domain }/"
  end
  
  protected
    def setup_email(<%= file_name %>)
      @recipients  = "#{<%= file_name %>.email}"
      @from        = Site.current.email
      @subject     = "[#{ Site.current.name }] "
      @sent_on     = Time.now
      @body[:<%= file_name %>] = <%= file_name %>
    end
end
