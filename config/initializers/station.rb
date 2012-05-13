ActiveSupport.on_load(:after_initialize) do

  # Initialize all Singular Agents
  if SingularAgent.table_exists?
    SingularAgent
    Anonymous.current
    Anyone.current
    Authenticated.current
  end

  if Site.table_exists?
    ActionMailer::Base.default_url_options[:host] = Site.current.domain
  end
end
