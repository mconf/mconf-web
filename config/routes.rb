# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# The priority is based upon order of creation:
# first created -> highest priority.
#
# Sample of regular route:
#   match 'products/:id' => 'catalog#view'
# Keep in mind you can assign values other than :controller and :action
#
# Sample of named route:
#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
# This route can be invoked with purchase_url(:id => product.id)
#
# See how all your routes lay out with "rake routes"

Mconf::Application.routes.draw do

  # devise
  controllers = { :sessions => "sessions", :registrations => "registrations" }
  paths = { :sign_in => "login", :sign_out => "logout", :sign_up => "signup" }
  devise_for :users, :path_names => paths, :controllers => controllers
  devise_scope :user do
    get "login", :to => "sessions#new"
    get "logout", :to => "sessions#destroy"
    get "register", :to => "registrations#new"
  end

  # bigbluebutton_rails default routes
  bigbluebutton_routes :default, :controllers => { :servers => 'custom_bigbluebutton_servers', :rooms => 'custom_bigbluebutton_rooms' }

  # FIXME: Temporary, this should probably be done by bigbluebutton_rails
  match '/webconf/:id', :to => 'custom_bigbluebutton_rooms#invite',
                        :as => "join_webconf"

  # shibboleth controller
  match '/secure', :to => 'shibboleth#create', :as => "shibboleth"
  match '/secure/info', :to => 'shibboleth#info', :as => "shibboleth_info"

  resources :logos do
    collection do
      post :new
    end
  end

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
      post :leave
    end

    resources :users do
      resource :profile, :except => [:new, :create]
    end

    resource :webconference
    resources :readers

    resources :events do

      member do
        post :spam
        get :spam_lightbox
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
    end

    resources :posts do
      member do
        get :reply_post
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
    resources :news
  end

  resources :invitations do
    member do
      get :accept
    end
  end

  resources :permissions
  resources :admissions
  resources :memberships

  resources :users do
    get :fellow_users, :on => :collection, :defaults => { :format => 'json' }
    get :select_users, :on => :collection
    get :current, :on => :collection, :defaults => { :format => 'xml' }
    member do
      post :enable
      get :edit_bbb_room
    end

    resources :private_messages, :as => 'messages', :except => [:edit]
    resource :profile, :except => [:new, :create] do
      resource :logo
    end
    resource :avatar do
      member do
        post :precrop
      end
    end
  end

  # resources :roles # TODO: permissions

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

  # The unique Site is created in db/seeds and can only be edited
  resource :site, :only => [:show, :edit, :update]

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

  # Statistics
  match '/statistics', :to => 'statistics#show', :as => 'show_statistics'

  match '/reset_password/:reset_password_code', :to => 'users#reset_password', :as => 'reset_password'

  match 'get_file/:id', :to => 'machines#get_file', :as => 'get_file'

  # 'Hack' to show a custom 404 page.
  # See more at http://blog.igodigital.com/blog/notes-on-cyber-weekend-targeted-email-campaigns/custom-error-handling-in-rails-303
  # and http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
  unless Rails.application.config.consider_all_requests_local
    match '*not_found', :to => 'errors#error_404'
  end
end
