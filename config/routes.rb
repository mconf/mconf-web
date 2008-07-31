ActionController::Routing::Routes.draw do |map|

  map.resources :spaces do |space|
    space.resources :users do |user|
      user.resource :profile
    end

    space.resources :events
    space.resources :articles
    space.resources :attachments

    # Para el nuevo controlador de Grupos
    space.resources :groups
  end

  map.resources :events
  map.resources :articles
  map.resources :attachments

  map.resource :notifier

  # Esta no la entiendo:
  # resource en singular y machines en plural
  map.resource :machines  

  map.resources :users
  map.resources :roles

  #LOCALE CONTROLLER (GLOBALIZE)
  map.connect ':locale/:controller/:action/:id'  
  map.set 'locale/set/:id', :controller => 'locale' , :action => 'set'

  #SIMPLE_CAPTCHA CONTROLLER
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'

  #ROOT
  map.root :controller => 'spaces', :action => 'show', :space_id => 1,:container_id=> 1

  # #######################################################################
  # CMSplugin
  #
  # (se quedará obsoleto con la nueva versión del plugin)
  #  
  map.resources :posts, :member => { :media => :any,
                                     :get => :edit_media,
                                     :put => :update_media }
  map.resources :posts, :path_prefix => '/:container_type/:container_id',
                        :name_prefix => 'container_'

  CMS.contents.each do |content|
      map.resources content
      map.resources content, :path_prefix => '/:container_type/:container_id',
                             :name_prefix => 'container_'
  end
  
  map.open_id_complete 'session', { :open_id_complete => true,
                                    :conditions => { :method => :get },
                                    :controller => "sessions",
                                    :action => "create" }
  map.resource :session

  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:reset_password_code', :controller =>"users", :action => "reset_password"  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  #############################################################################

  ###########################################
  # RUTAS A LIMPIAR
  # #########################################
  #
  # Estas rutas están integradas en las de arriba. 
  # En cada una se anota dónde debería ir....
  #
  map.show_ajax '/:container_type/:container_id/events/show_ajax/:id', :controller => 'events', :action => 'show_ajax' #=> /spaces/:space_id/events/:id.rjs, EventsController#show.rjs
  map.show_ajax '/events/show_ajax/:id', :controller => 'events', :action => 'show_ajax' #=> /events/:id.rjs, EventsController#show.rjs
  map.show_calendar '/:container_type/:container_id/events/show_calendar', :controller => 'events', :action => 'show_calendar' #=>  /spaces/:space_id/events/index, EventsController#index
  map.show_calendar '/events/show_calendar', :controller => 'events', :action => 'show_calendar' #=>  /events/index, EventsController#index
 
  
  map.connect ':controller/:action.:format/:container_id' #=> A saber!
  map.connect ':controller/:action.:format/:container_id/:role_id' #=> A saber!
  
  #SPACES CONTROLLER
  map.add_user2 '/spaces/:space_id/add_user2', :controller => "spaces", :action => "add_user2" #=> /spaces/:space_id/users/new, UsersController#new
  map.register_user '/spaces/:space_id/register_user', :controller => "spaces", :action => "register_user" #=> /spaces/:space_id/users/create, UsersController#create
  map.remove_user '/spaces/:space_id/remove_user', :controller => "spaces", :action => "remove_user" #=> /spaces/:space_id/users/:id, UsersController#delete
  map.add_user '/spaces/:space_id/add_user', :controller=> 'spaces', :action => 'add_user' #=> /spaces/:space_id/users/create, UsersController#create
   map.register '/spaces/:space_id/register', :controller=> 'users', :action => 'new' # ??? no sé cuál es la diferencia con add_users
  
  #explicit routes ORDERED BY CONTROLLER
  
map.search_articles '/:container_type/:container_id/search_articles', :controller => 'articles', :action=> 'search_articles' #=> /search/articles, SearchController
 
map.search_all '/:container_type/:container_id/search_all', :controller => 'home', :action=> 'search' #=> /search, SearchController
  #EVENTS CONTROLLER
  map.show_timetable '/events/show_timetable' , :controller => "events", :action => "show_timetable" #=> /events, EventsController#index
  map.show_summary '/:container_type/:container_id/show_summary/:id' , :controller => "events", :action => "show_summary" #=> /events/:id.rjs, EventsController#show.rjs
  map.add_participant '/add_participant', :controller => 'events', :action => 'add_participant' #=> ParticipantsController o (NO REST) Añadir a events :member => [ :add_participant ]
  map.remove_participant '/remove_participant', :controller => 'events', :action => 'remove_participant' #=> ParticipantsController o (NO REST) Añadir a events :member => [ :remove_participant ]
  map.export_ical '/events/:id/export_ical', :controller => 'events' , :action => 'export_ical' #=> /events/:id.ical, EventsController#show.ical
  map.resources :events, :member => 'export_ical' #=> Borrar con la de arriba
  map.remove_time '/:container_type/:container_id/remove_time', :controller => 'events', :action => 'remove_time' #=> TimesController o (NO REST) Añadir a events :member => [ :remove_time ]
  map.add_time '/:container_type/:container_id/add_time', :controller => 'events', :action => 'add_time' #=> TimesController o (NO REST) Añadir a events :member => [ :add_time ]
  map.copy_next_week '/:container_type/:container_id/copy_next_week', :controller => 'events', :action => 'copy_next_week' #=> TimesController o (NO REST) Añadir a events :member => [ :copy_next_week ]
  
  map.search '/:container_type/:container_id/search', :controller => 'events', :action => 'search' #=> /search/events, SearchController
  map.search_by_tag '/:container_type/:container_id/tags/:tag', :controller => 'events', :action => 'search_by_tag' #=> /tags/:id/events, TagsController
  map.search_events '/:container_type/:container_id/search_events', :controller => 'events', :action => 'search_events' #=> /search/events, SearchController
  map.advanced_search_events '/:container_type/:container_id/advanced_search_events', :controller => 'events', :action => 'advanced_search_events' #=> /search/avanced/events, SearchController
  map.search_by_title '/:container_type/:container_id/search_by_title', :controller => 'events', :action => 'search_by_title' #=> /search/title/events, SearchController
 map.search_in_description '/:container_type/:container_id/search_description', :controller => 'events', :action => 'search_in_description' #=> /search/description/events, SearchController
 map.search_by_date '/:container_type/:container_id/search_by_date', :controller => 'events', :action => 'search_by_date' #=> /search/date/events, SearchController

 map.advanced_search '/:container_type/:container_id/advanced_search', :controller => 'events', :action => 'advanced_search' #=> otra vez ????????
 map.title '/:container_type/:container_id/title_search', :controller => 'events', :action => 'title' #=> /search/title, SearchController
 map.description '/:container_type/:container_id/description_search', :controller => 'events', :action => 'description' #=> /search/description, SearchController
 map.clean '/:container_type/:container_id/clean', :controller => 'events', :action => 'clean' #=> SearchController ??
  map.dates '/:container_type/:container_id/search_by_dates', :controller => 'events', :action => 'dates'
   #PROFILES CONTROLLER
  map.profile '/:container_type/:container_id/users/:user_id/profile', :controller => 'profiles' , :action => 'show' #=> /users/:user_id/profile, ProfileController#show, se llama con: user_profile_path(@user) 
  map.new_profile '/:container_type/:container_id/users/:user_id/profile/new', :controller => 'profiles' , :action => 'new'    #=> /users/:user_id/profile/new, ProfileController#new, se llama con: new_user_profile_path(@user) 
  map.vcard '/users/:user_id/vcard/', :controller => 'profiles' , :action => 'vcard'    #=> /users/:user_id/profile.vcf, ProfileController#show.vcf, se llama con: formatted_user_profile_path(@user, :vcf) 
  map.hcard '/users/:user_id/hcard/', :controller => 'profiles' , :action => 'hcard'    #=> Esto habría que integrarlo en el propio show, ya que es un microformato
  #USERS CONTROLLER
  map.show_space_users '/:container_type/:container_id/space_users', :controller => 'users' , :action => 'show_space_users'  #=> /spaces/:space_id/users, UsersController#index 
  map.clean_show '/clean_event', :controller => 'events', :action => 'clean_show' #=> ????
  map.clean '/clean_search', :controller => 'users', :action => 'clean' #=> ?????
 map.organization '/search_in_organization', :controller => 'users', :action => 'organization' #=> ???????
 map.search_by_tag '/search_tag', :controller => 'users', :action=> 'search_by_tag' #=> /tags/:id/users, TagsController o UsersController ?
  map.search_users '/:container_type/:container_id/search_users', :controller => 'users', :action=> 'search_users' #=> /search/users, SearchController
  map.manage_users '/:container_type/:container_id/manage_users', :controller => 'users', :action => 'manage_users' #=> /spaces/:space_id/users, UserController#index
  map.search_users2 '/:container_type/:container_id/search_all_users', :controller => 'users', :action => 'search_users2' #=> /search/users ???
  map.reset_search 'reset_search', :controller => 'users', :action => 'reset_search' #=> SearchController ????
  map.clean2 '/clean2_search', :controller => 'users', :action => 'clean2' #=> Ni idea
  #MACHINES CONTROLLER
  map.my_mailer 'machines/my_mailer', :controller => 'machines' , :action => 'my_mailer'
  map.contact_mail 'contact_mail' , :controller => 'machines', :action => 'contact_mail'
  map.list_use_machines 'machines/list_user_machines' , :controller => 'machines' , :action => 'list_user_machines' #=> ????
  map.get_file 'get_file/:id' ,  :controller => "machines", :action => "get_file" #=> ??? 
  map.manage_resources '/manage_resources', :controller => 'machines', :action => 'manage_resources' #=> ??? 
#ROLES CONTROLLER
map.save_group '/:container_type/:container_id/save_group', :controller => 'roles', :action=> 'save_group' #=> /spaces/:space_id/groups, GroupsController
map.create_group '/:container_type/:container_id/create_group', :controller => 'roles', :action=> 'create_group' #=> /spaces/:space_id/groups, GroupsController
map.show_groups '/:container_type/:container_id/show_groups', :controller => 'roles', :action=> 'show_groups' #=> /spaces/:space_id/groups/:id, GroupsController#show
map.delete_group '/:container_type/:container_id/delete_group/:group_id', :controller => 'roles', :action=> 'delete_group' #=> /spaces/:space_id/groups/:id, GroupsController#destroy
map.group_details '/:container_type/:container_id/group_details/:group_id', :controller => 'roles', :action=> 'group_details' #=> /spaces/:space_id/groups/:id, GroupsController#show
map.edit_group '/:container_type/:container_id/edit_group/:group_id', :controller => 'roles', :action=> 'edit_group' #=> /spaces/:space_id/groups/:id/edit, GroupsController#edit
map.update_group '/:container_type/:container_id/update_group/:group_id', :controller => 'roles', :action=> 'update_group' #=> /spaces/:space_id/groups/:id, GroupsController#update


end
