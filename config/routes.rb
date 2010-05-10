ActionController::Routing::Routes.draw do |map|
  Translate::Routes.translation_ui(map)

  map.p '/p', :controller => 'p', :action => 'index'
  # Route for text logos creation

  
  map.connect '/ui/:action', :controller => 'ui'

  #Global search
  map.search_all '/search.:format', :controller => 'search', :action=> 'index' #=> /search, SearchController  
  map.search_by_tag '/tags/:tag', :controller => 'search', :action => 'tag' #=> /tags/:id/events, TagsController (actualmente es parte del searchcontroller)  

  #Search in the space
  map.space_search_all '/spaces/:space_id/search', :controller => 'search', :action=> 'index' #=> /search, SearchController  
  map.space_search_by_tag '/spaces/:space_id/tags/:tag', :controller => 'search', :action => 'tag' #=> /tags/:id/events, TagsController (actualmente es parte del searchcontroller)  
  
  
  map.resources :logos
  
  map.resources :machines, :collection => [:contact_mail, :my_mailer ]

  map.resources :spaces, :member => {:enable => :post} do |space|
    space.resources :users do |user|
      user.resource :profile
    end

    space.resources :readers
    space.resources :events,
                     :collection => [:add_time, :copy_next_week, :remove_time],
                     :member => { :token => :get, :spam => :post, :spam_lightbox => :get, :start => :post } do |event|
      event.resources :invitations
      event.resources :participants
      event.resource :agenda, :member => {:generate_pdf => :get}
      event.resource :agenda do |agenda|
        agenda.resources :agenda_dividers
        agenda.resources :agenda_entries
        agenda.resources :agenda_entries do |entry|
          entry.resource :attachment
        end
        agenda.resources :agenda_record_entries
      end
      event.resource :logo, :controller => 'event_logos', :member => {:precrop => :post}
    end

    space.resources :posts, :member => {:spam => :post, :spam_lightbox => :get}
    
    #Route to delete attachment collections with a DELETE to /:space_id/attachments
    space.attachments 'attachments', :controller => 'attachments' , :action => 'delete_collection', :conditions => { :method => :delete }
    space.resources :attachments,
                    :member => {:edit_tags => :get} 
    
    space.resources :entries
    space.resource :logo, :member => {:precrop => :post}

    space.resources :groups
    space.resources :admissions
    space.resources :invitations
    space.resources :join_requests
#    space.resources :event_invitations
    space.resources :performances
    space.resources :news
  end

  map.resources :invitations, :member => [ :accept ]
  map.resources :performances
  map.resources :admissions

  map.resources :memberships
  map.resources :groups
  map.resources :groups do |group|
    group.resources :memberships
  end

  #map.resources :posts
  #map.resources :attachments

  #map.resource :notifier

  map.resources :users, :member => {:enable => :post} do |user|
     user.resources :messages, :controller => 'private_messages' 
     user.resource :profile do |profile|
          profile.resource :logo
     end
     user.resource :avatar, :member => {:precrop => :post}
  end
  map.resources :roles
  map.resource :site
  map.resource :home
  map.resources :feedback
  map.resource :session_locale
  map.manage_users '/manage/users', :controller => 'manage', :action => 'users'
  map.manage_spaces '/manage/spaces', :controller => 'manage', :action => 'spaces'
  map.manage_spam '/manage/spam', :controller => 'manage', :action => 'spam'
  
#LOCALE CONTROLLER (GLOBALIZE)
  map.connect ':locale/:controller/:action/:id'  
  map.set 'locale/set/:id', :controller => 'locale' , :action => 'set'

  #SIMPLE_CAPTCHA CONTROLLER
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'

  #ROOT
  map.root :controller => 'frontpage'
  map.about 'about', :controller => 'frontpage', :action => 'about'
  map.about2 'about2', :controller => 'frontpage', :action => 'about2'
  map.help 'help', :controller => 'help', :action => 'index'
  

  # #######################################################################
  # CMSplugin
  #
  # (se quedará obsoleto con la nueva versión del plugin)
  #  
  
  map.open_id_complete 'session/open_id_complete',
                       { :open_id_complete => true,
                         :conditions => { :method => :get },
                         :controller => "sessions",
                         :action => "create" }
  map.resource :session

  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.lost_password '/lost_password', :controller => 'users', :action => 'lost_password'
  map.reset_password '/reset_password/:reset_password_code', :controller =>"users", :action => "reset_password"  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  #############################################################################
  ## Rutas que hemos cambiado y que puede ser que ya estén bien, TENEMOS QUE PASARLOS A MEMBER => [:LOQUESEA]
  #map.add_time '/spaces/:space_id/add_time', :controller => 'events', :action => 'add_time' #=> TimesController o (NO REST) Añadir a events :member => [ :add_time ]
  #map.copy_next_week '/spaces/:space_id/copy_next_week', :controller => 'events', :action => 'copy_next_week' #=> TimesController o (NO REST) Añadir a events :member => [ :copy_next_week ]
  #map.remove_time '/:container_type/:container_id/remove_time', :controller => 'events', :action => 'remove_time' #=> TimesController o (NO REST) Añadir a events :member => [ :remove_time ]
  
  map.change_space '/change_space', :controller => 'spaces', :action => 'change_space'

  Translate::Routes.translation_ui(map) if RAILS_ENV != "production"
  
  #  map.register '/spaces/:space_id/register', :controller=> 'users', :action => 'new'
  

  

  ###########################################
  # RUTAS A LIMPIAR
  # #########################################
  #
  # Estas rutas están integradas en las de arriba. 
  # En cada una se anota dónde debería ir....
  #
  #!arreglada=>map.show_ajax '/spaces/:space_id/events/show_ajax/:id', :controller => 'events', :action => 'show_ajax' #=> /spaces/:space_id/events/:id.rjs, EventsController#show.rjs
  #!arreglada=>map.show_ajax '/events/show_ajax/:id', :controller => 'events', :action => 'show_ajax' #=> /events/:id.rjs, EventsController#show.rjs
  #!arreglada=>map.export_ical '/events/:id/export_ical', :controller => 'events' , :action => 'export_ical' #=> /events/:id.ical, EventsController#show.ical
  
    
  #map.connect ':controller/:action.:format/:container_id' #=> A saber!
  #map.connect ':controller/:action.:format/:container_id/:role_id' #=> A saber!
  
  #SPACES CONTROLLER 
  #!arreglada=>map.add_user2 '/spaces/:space_id/add_user2', :controller => "spaces", :action => "add_user2" #=> /spaces/:space_id/users/new, UsersController#new
  #!arreglada=>map.register_user '/spaces/:space_id/register_user', :controller => "spaces", :action => "register_user" #=> /spaces/:space_id/users/create, UsersController#create
  #!arreglada=>map.remove_user '/spaces/:space_id/remove_user', :controller => "spaces", :action => "remove_user" #=> /spaces/:space_id/users/:id, UsersController#delete
  #!arreglada=>map.add_user '/spaces/:space_id/add_user', :controller=> 'spaces', :action => 'add_user' #=> /spaces/:space_id/users/create, UsersController#create
  #!arreglada=>map.register '/spaces/:space_id/register', :controller=> 'users', :action => 'new' # ??? no sé cuál es la diferencia con add_users
  
  #explicit routes ORDERED BY CONTROLLER
  


  #EVENTS CONTROLLER

  #!arreglada=>  map.show_timetable '/events/show_timetable' , :controller => "events", :action => "show_timetable" #=> /events, EventsController#index
  #!arreglada=>  map.show_summary '/spaces/:space_id/show_summary/:id' , :controller => "events", :action => "show_summary" #=> /events/:id.rjs, EventsController#show.rjs
  
  
 
  #!arreglada=> map.title '/spaces/:space_id/title_search', :controller => 'events', :action => 'title' #=> /search/title, SearchController
  #!arreglada=> map.description '/spaces/:space_id/description_search', :controller => 'events', :action => 'description' #=> /search/description, SearchController
  #!arreglada=> TODO duda 1 map.clean '/spaces/:space_id/clean', :controller => 'events', :action => 'clean' #=> SearchController ??
  #!arreglada=>  map.dates '/spaces/:space_id/search_by_dates', :controller => 'events', :action => 'dates'

   #PROFILES CONTROLLER

  #!arreglada=>map.profile '/spaces/:space_id/users/:user_id/profile', :controller => 'profiles' , :action => 'show' #=> /users/:user_id/profile, ProfileController#show, se llama con: user_profile_path(@user) 
  #!arreglada=>map.new_profile '/spaces/:space_id/users/:user_id/profile/new', :controller => 'profiles' , :action => 'new'    #=> /users/:user_id/profile/new, ProfileController#new, se llama con: new_user_profile_path(@user) 
  #!arreglada=>map.vcard '/users/:user_id/vcard/', :controller => 'profiles' , :action => 'vcard'    #=> /users/:user_id/profile.vcf, ProfileController#show.vcf, se llama con: formatted_user_profile_path(@user, :vcf) 
  #!arreglada=>map.hcard '/users/:user_id/hcard/', :controller => 'profiles' , :action => 'hcard'    #=> Esto habría que integrarlo en el propio show, ya que es un microformato

  #USERS CONTROLLER

  #!arreglada=> esta no se usa en ningun sitio map.show_space_users '/spaces/:space_id/space_users', :controller => 'users' , :action => 'show_space_users'  #=> /spaces/:space_id/users, UsersController#index 
  #!arreglada=> map.clean_show '/clean_event', :controller => 'events', :action => 'clean_show' #=> ????
  #!arreglada=> map.clean '/clean_search', :controller => 'users', :action => 'clean' #=> ?????
  #!arreglada=> TODO duda 3 map.organization '/search_in_organization', :controller => 'users', :action => 'organization' #=> ???????
  #!arreglada=>  map.search_by_tag '/search_tag', :controller => 'users', :action=> 'search_by_tag' #=> /tags/:id/users, TagsController o UsersController ?
  #!arreglada=>  map.search_users '/spaces/:space_id/search_users', :controller => 'users', :action=> 'search_users' #=> /search/users, SearchController
  #!arreglada=>  map.manage_users '/spaces/:space_id/manage_users', :controller => 'users', :action => 'manage_users' #=> /spaces/:space_id/users, UserController#index (ELIMINABLE)
  #!arreglada=>  map.search_users2 '/spaces/:space_id/search_all_users', :controller => 'users', :action => 'search_users2' #=> /search/users ??? (NOTA: no se usa en ninguna vista!!)
  #!arreglada=> TODO duda 3 map.reset_search 'reset_search', :controller => 'users', :action => 'reset_search' #=> SearchController ????
  #!arreglada=> map.clean2 '/clean2_search', :controller => 'users', :action => 'clean2' #=> Ni idea

  #MACHINES CONTROLLER
  #map.my_mailer 'machines/my_mailer', :controller => 'machines' , :action => 'my_mailer'
  #map.contact_mail 'contact_mail' , :controller => 'machines', :action => 'contact_mail'
  map.get_file 'get_file/:id' ,  :controller => "machines", :action => "get_file" #=> ??? 
  
  #map.list_use_machines 'machines/list_user_machines' , :controller => 'machines' , :action => 'list_user_machines' #=> /machines?user=id  
  #map.manage_resources '/manage_resources', :controller => 'machines', :action => 'manage_resources' #=> /machines
#ROLES CONTROLLER
=begin
map.save_group '/spaces/:space_id/save_group', :controller => 'roles', :action=> 'save_group' #=> /spaces/:space_id/groups, GroupsController
map.create_group '/spaces/:space_id/create_group', :controller => 'roles', :action=> 'create_group' #=> /spaces/:space_id/groups, GroupsController
map.show_groups '/spaces/:space_id/show_groups', :controller => 'roles', :action=> 'show_groups' #=> /spaces/:space_id/groups/:id, GroupsController#show
map.delete_group '/spaces/:space_id/delete_group/:group_id', :controller => 'roles', :action=> 'delete_group' #=> /spaces/:space_id/groups/:id, GroupsController#destroy
map.group_details '/spaces/:space_id/group_details/:group_id', :controller => 'roles', :action=> 'group_details' #=> /spaces/:space_id/groups/:id, GroupsController#show
map.edit_group '/spaces/:space_id/edit_group/:group_id', :controller => 'roles', :action=> 'edit_group' #=> /spaces/:space_id/groups/:id/edit, GroupsController#edit
map.update_group '/spaces/:space_id/update_group/:group_id', :controller => 'roles', :action=> 'update_group' #=> /spaces/:space_id/groups/:id, GroupsController#update
=end
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
