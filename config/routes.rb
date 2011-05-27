Vcc::Application.routes.draw do

  bigbluebutton_routes :default, :controllers => { :servers => 'custom_bigbluebutton_servers', :rooms => 'custom_bigbluebutton_rooms' }

  #Translate::Routes.translation_ui(map) if RAILS_ENV != "production"
  scope '/translate' do
    match '/translate_list', :to => 'translate#index'
    match '/translate', :to => 'translate#translate'
    match '/translate_reload', :to => 'translate#reload', :as => 'translate_reload'
  end

  # Experimental chat
  #match '/p', :to => 'p#index', :as => 'p'

  match '/ui/:action', :to => 'ui'

  # Global search
  match '/search(.:format)', :to => 'search#index', :as => 'search_all' #=> /search, SearchController
  match '/tags/:tag', :to => 'search#tag', :as => 'search_by_tag' #=> /tags/:id/events, TagsController (actualmente es parte del searchcontroller)

  # Search in the space
  match '/spaces/:space_id/search', :to => 'search#index', :as => 'space_search_all' #=> /search, SearchController
  match '/spaces/:space_id/tags/:tag', :to => 'search#tag', :as => 'space_search_by_tag' #=> /tags/:id/events, TagsController (actualmente es parte del searchcontroller)

  resources :logos do
    collection do
      post :new
    end
  end
  resources :screencasts

  resources :machines do
    collection do
      get :contact_mail
      get :my_mailer
    end
  end

  resources :spaces do

    bigbluebutton_routes :room_matchers

    member do
      post :enable
    end

    resources :users do
      resource :profile, :except => [:new, :create]
    end

    resource :webconference
    resources :videos
    resources :readers

    resources :events do

      member do
        get :token
        post :spam
        get :spam_lightbox
        post :start
        get :chat
        get :webstats
        get :webmap
      end

      collection do
        get :add_time
        get :copy_next_week
        get :remove_time
      end

      resources :invitations
      resources :participants

      resource :agenda do
        member do
          get :generate_pdf
        end
      end

      resource :agenda do
        resources :agenda_dividers
        resources :agenda_entries
        resources :agenda_entries do
          resource :attachment
        end
        resources :agenda_record_entries
      end

## TODO check
      #event.resource :logo, :controller => 'event_logos', :member => {:precrop => :post}
      # limit to only create, update and precrop
      resource :logo, :controller => 'event_logos' do
        member do
          post :precrop
        end
      end
##
      resource :chat_log
    end

    resources :posts do
      member do
        post :spam
        get :spam_lightbox
      end
    end

## TODO check
    #Route to delete attachment collections with a DELETE to /:space_id/attachments
    #space.attachments 'attachments', :controller => 'attachments' , :action => 'delete_collection', :conditions => { :method => :delete }
    delete 'attachments', :to => 'attachments#delete_collection', :as => 'attachments'
##
    resources :attachments do
      member do
        get :edit_tags
      end
    end

    resources :entries
    resource :logo do
      member do
        post :precrop
      end
    end

    resources :groups
    resources :admissions
    resources :invitations
    resources :join_requests
    # resources :event_invitations
    resources :performances
    resources :news
  end

  resources :invitations do
    member do
      get :accept
    end
  end

  resources :performances
  resources :admissions

  resources :memberships
  resources :groups
  resources :groups do
    resources :memberships
  end

  #resources :posts
  #resources :attachments
  resources :attachment_videos

  #resource :notifier

  resources :users do
    member do
      post :enable
    end

    resources :private_messages, :as => 'messages'
    resource :profile, :except => [:new, :create] do
      resource :logo
    end
    resource :avatar do
      member do
        post :precrop
      end
    end
  end

  resources :roles
  resource :site

  resource :home do
    member do
      get :new_room, :as => 'newroom'
    end
  end

  resource :invite do
    member do
      get :invite_room, :as => 'inviteroom'
      post :send_invite, :as => 'sendinvite'
    end
  end

  resources :feedback
  resource :session_locale

  match '/manage/users', :to => 'manage#users', :as => 'manage_users'
  match '/manage/spaces', :to => 'manage#spaces', :as => 'manage_spaces'
  match '/manage/spam', :to => 'manage#spam', :as => 'manage_spam'

  # Locale controller (globalize)
  match ':locale/:controller/:action/:id'
  match 'locale/set/:id', :to => 'locale#set', :as => 'set'

  # simple_captcha controller
  #match '/simple_captcha(/:id)', :to => 'simple_captcha#show'

  # root
  root :to => 'frontpage#index'
  match 'help(/:action)', :to => 'help#index', :as => 'help'
  match 'faq', :to => 'faq#index', :as => 'faq'
  #match 'perf_indicator', :to => 'frontpage#performance', :as => 'perf_indicator'
  #match 'about', :to => 'frontpage#about', :as => 'about' # TODO Create an about for Mconf

  resource :session

  match '/login', :to => 'sessions#new', :as => 'login'
  match '/logout', :to => 'sessions#destroy', :as => 'logout'
  match '/signup', :to => 'users#new', :as => 'signup'
  match '/lost_password', :to => 'users#lost_password', :as => 'lost_password'
  match '/reset_password/:reset_password_code', :to => 'users#reset_password', :as => 'reset_password'
  match '/activate/:activation_code', :to => 'users#activate', :as => 'activate', :activation_code => nil

  match '/change_space', :to => 'spaces#change_space', :as => 'change_space'

  match 'get_file/:id', :to => 'machines#get_file', :as => 'get_file'
end
