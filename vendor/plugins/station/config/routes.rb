ActionController::Routing::Routes.draw do |map|
  map.openid_server 'openid_server', :controller => 'openid_server'

  map.open_id_complete 'session/open_id_complete', 
                       { :controller => 'sessions', 
                         :action     => 'create',
                         :conditions => { :method => :get },
                         :open_id_complete => true }

  map.resource :session

  map.login 'login',   :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'

  if ActiveRecord::Agent.activation_class
    map.activate 'activate/:activation_code', 
             :controller => ActiveRecord::Agent.activation_class.to_s.tableize, 
             :action => 'activate', 
             :activation_code => nil
  end

  if ActiveRecord::Agent::authentication_classes(:login_and_password).any?
    map.lost_password 'lost_password', 
                    :controller => ActiveRecord::Agent.authentication_classes(:login_and_password).first.to_s.tableize,
                    :action => 'lost_password'
    map.reset_password 'reset_password/:reset_password_code', 
                   :controller => ActiveRecord::Agent.authentication_classes(:login_and_password).first.to_s.tableize,
                   :action => 'reset_password',
                   :reset_password_code => nil
  end

  if ActiveRecord::Agent::authentication_classes(:openid).any?
    map.resources :open_id_ownings
  end

  map.resources :tags

  map.resource :site do |site|
    if Site.table_exists?
      site.with_options :requirements => { :site_id => Site.current.id } do |local_site|
        local_site.resources :performances
        local_site.resources *ActiveRecord::Resource.symbols
      end
    end
  end

  map.resources *( ( ActiveRecord::Resource.symbols | 
                 ActiveRecord::Content.symbols  | 
                 ActiveRecord::Agent.symbols ) - 
                ActiveRecord::Container.symbols 
             )

  ActiveRecord::Container.symbols.each do |container_sym|
    next if container_sym == :sites
    map.resources(container_sym) do |container|
      container.resources(*container_sym.to_class.contents)
      container.resources :sources, :member => { :import => :get }
      container.resources :tags
    end
  end
  map.resources :sources, :member => { :import => :get }

  map.resources :logos

  map.resources(*(ActiveRecord::Logoable.symbols - Array(:sites))) do |logoable|
    logoable.resource :logo
  end

  map.resources :roles
  map.resources :invitations, :member => { :accept => :get }

  map.resources(*ActiveRecord::Stage.symbols - Array(:sites)) do |stage|
    stage.resources :performances
    stage.resources :invitations
    stage.resources :join_requests
  end

  map.resources :performances
end
