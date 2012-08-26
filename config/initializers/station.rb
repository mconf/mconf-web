ActiveSupport.on_load(:after_initialize) do
  if Site.table_exists?
    ActionMailer::Base.default_url_options[:host] = Site.current.domain
  end
end
