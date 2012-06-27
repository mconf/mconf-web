# The priority is based upon order of creation:
# first created -> highest priority.

# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action

# Sample of named route:
#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
# This route can be invoked with purchase_url(:id => product.id)

# See how all your routes lay out with "rake routes"

Mconf::Application.routes.draw do

  # bigbluebutton_rails default routes
  bigbluebutton_routes :default, :controllers => { :servers => 'custom_bigbluebutton_servers', :rooms => 'custom_bigbluebutton_rooms' }

  # FIXME: Temporary, this should probably be done by bigbluebutton_rails
  match '/webconf/:id', :to => 'custom_bigbluebutton_rooms#invite',
                        :as => "join_webconf"

  # shibboleth controller
  match '/secure', :to => 'shibboleth#create', :as => "shibboleth"
  match '/secure/info', :to => 'shibboleth#info', :as => "shibboleth_info"

  # Experimental chat
  #match '/p', :to => 'p#index', :as => 'p'

  # Global search
  #match '/search(.:format)', :to => 'search#index', :as => 'search_all' #=> /search, SearchController
  #match '/tags/:tag', :to => 'search#tag', :as => 'search_by_tag' #=> /tags/:id/events, TagsController (actualmente es parte del searchcontroller)

  # Search in the space
  #match '/spaces/:space_id/search', :to => 'search#index', :as => 'space_search_all' #=> /search, SearchController
  #match '/spaces/:space_id/tags/:tag', :to => 'search#tag', :as => 'space_search_by_tag' #=> /tags/:id/events, TagsController (actualmente es parte del searchcontroller)

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
    resources :readers

    resources :events do

      member do
        get :token
        post :spam
        get :spam_lightbox
        post :start
        get :chat
      end

      collection do
        get :add_time
        get :copy_next_week
        get :remove_time
      end

      resources :invitations
      resources :participants

      resource :logo, :controller => 'event_logos' do
        member do
          post :precrop
        end
      end

      resource :chat_log
    end

    resources :posts do
      member do
        post :spam
        get :spam_lightbox
      end
    end

    delete 'attachments', :to => 'attachments#delete_collection', :as => 'attachments'

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

    resources :admissions
    resources :invitations
    resources :join_requests
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
  resources :attachment_videos

  resources :users do
    get :select_users, :on => :collection
    get :xmpp_current_user, :on => :collection
    member do
      post :enable
      get :edit_bbb_room
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
      get :user_rooms
    end
  end

  resource :invite do
    member do
      get :invite_room, :as => 'inviteroom'
      post :send_invite, :as => 'sendinvite'
      get :send_notification, :as => 'sendnotification'
    end
  end

  resources :feedback do
    collection do
      get :webconf
    end
  end

  match '/manage/users', :to => 'manage#users', :as => 'manage_users'
  match '/manage/spaces', :to => 'manage#spaces', :as => 'manage_spaces'
  match '/manage/spam', :to => 'manage#spam', :as => 'manage_spam'

  # Locale controller (globalize)
  resource :session_locale
  match ':locale/:controller/:action/:id'
  match 'locale/set/:id', :to => 'locale#set', :as => 'set'

  # root
  root :to => 'frontpage#show'

  # FAQ
  match 'help', :to => 'faq#show', :as => 'help'
  match 'faq', :to => 'faq#show', :as => 'faq'

  resource :session

  match '/login', :to => 'sessions#new', :as => 'login'
  match '/logout', :to => 'sessions#destroy', :as => 'logout'
  match '/signup', :to => 'users#new', :as => 'signup'
  match '/lost_password', :to => 'users#lost_password', :as => 'lost_password'
  match '/resend_confirmation', :to => 'users#resend_confirmation', :as => 'resend_confirmation'
  match '/xmpp/me', :to => 'users#xmpp_current_user', :as => 'xmpp_me', :defaults => { :format => 'xml' }
  match '/reset_password/:reset_password_code', :to => 'users#reset_password', :as => 'reset_password'
  match '/activate/:activation_code', :to => 'users#activate', :as => 'activate', :activation_code => nil

  match 'get_file/:id', :to => 'machines#get_file', :as => 'get_file'
end
