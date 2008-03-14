ActionController::Routing::Routes.draw do |map|
  map.resources :posts, :member => { :get => :edit_media,
                                     :put => :update_media }
  map.resources :posts, :path_prefix => '/:container_type/:container_id',
                        :name_prefix => 'container_'

  CMS.contents.each do |content|
      map.resources content
      map.resources content, :path_prefix => '/:container_type/:container_id',
                             :name_prefix => 'container_'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
  
  map.resources :profiles
  map.resources :users, :member=> 'forgot_password2'
  map.resource  :sessions
  map.resource :notifier
  map.resource :machines
  map.resources :events, :memeber =>'export_ical'
  map.resources :users do |users|
      users.resources :profiles  
  end
  #explicit routes ORDERED BY CONTROLLER
  
  #EVENTS CONTROLLER
  map.show_timetable '/events/show_timetable' , :controller => "events", :action => "show_timetable"
  map.show_summary '/show_summary/:id' , :controller => "events", :action => "show_summary"
  map.add_participant '/add_participant', :controller => 'events', :action => 'add_participant'
  map.remove_participant '/remove_participant', :controller => 'events', :action => 'remove_participant'
  map.export_ical '/export_ical/:id', :controller => 'events' , :action => 'export_ical'
  map.remove_time '/remove_time', :controller => 'events', :action => 'remove_time'
  map.add_time '/add_time', :controller => 'events', :action => 'add_time'
  map.copy_next_week '/copy_next_week', :controller => 'events', :action => 'copy_next_week'
  map.home '', :controller => 'events', :action => 'show'
  map.search '/search', :controller => 'events', :action => 'search'
  # Acabar esto.........map.search_by_tag '/search_tag'

  map.search_events '/search_events', :controller => 'events', :action => 'search_events'
  #PROFILES CONTROLLER
  map.vcard '/users/profiles/vcard/:id', :controller => 'profiles' , :action => 'vcard'   
  map.hcard '/users/profiles/hcard/:id', :controller => 'profiles' , :action => 'hcard'   
  #USERS CONTROLLER
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot_password'
  map.connect 'reset_password/:id', :controller =>"users", :action => "reset_password"  
  map.connect 'users/:email', :controller => "users", :action => "forgot_password2"
  map.connect 'confirm_email/:hash', :controller => "users", :action => "confirm_email"
  map.manage_users '/manage_users', :controller => 'users', :action => 'manage_users'
   #SESSIONS CONTROLLER 
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  #LOCALE CONTROLLER (GLOBALIZE)
  map.connect ':locale/:controller/:action/:id'  
  map.set 'locale/set/:id', :controller => 'locale' , :action => 'set'
  #MACHINES CONTROLLER
  map.my_mailer 'machines/my_mailer', :controller => 'machines' , :action => 'my_mailer'
  map.contact_mail 'contact_mail' , :controller => 'machines', :action => 'contact_mail'
  map.list_use_machines 'machines/list_user_machines' , :controller => 'machines' , :action => 'list_user_machines'
  map.get_file 'get_file/:id' ,  :controller => "machines", :action => "get_file"  
  map.manage_resources '/manage_resources', :controller => 'machines', :action => 'manage_resources'  
  #SIMPLE_CAPTCHA CONTROLLER
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  
end
