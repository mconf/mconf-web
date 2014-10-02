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
  root :to => 'frontpage#show'

  constraints CanAccessResque do
    mount Resque::Server, :at => 'manage/resque'
  end

  # devise
  controllers = { :sessions => "sessions", :registrations => "registrations",
                  :passwords => "passwords", :confirmations => "confirmations" }
  paths = { :sign_in => "login", :sign_out => "logout", :sign_up => "signup" }
  devise_for :users, :path_names => paths, :controllers => controllers
  devise_scope :user do
    get "login", :to => "sessions#new"
    get "logout", :to => "sessions#destroy"
    get "register", :to => "registrations#new"
  end

  # bigbluebutton_rails default routes
  bigbluebutton_routes :default, :controllers => {
    :servers => 'custom_bigbluebutton_servers',
    :rooms => 'custom_bigbluebutton_rooms',
    :recordings => 'custom_bigbluebutton_recordings'
  }
  # register a few custom routes that were added to bigbluebutton_rails
  get '/bigbluebutton/rooms/:id/join_options',
    :to => 'custom_bigbluebutton_rooms#join_options',
    :as => "join_options_bigbluebutton_room"
  get '/bigbluebutton/rooms/:id/invitation',
    :to => 'custom_bigbluebutton_rooms#invitation',
    :as => "invitation_bigbluebutton_room"
  post '/bigbluebutton/rooms/:id/send_invitation',
    :to => 'custom_bigbluebutton_rooms#send_invitation',
    :as => "send_invitation_bigbluebutton_room"
  # shortcut route to join webconference rooms
  get '/webconf/:id',
    :to => 'custom_bigbluebutton_rooms#invite_userid',
    :as => "join_webconf"

  # event module
  if Mconf::Modules.mod_loaded?('events')
    # For invitations
    resources :events, :only =>[] do
      post :send_invitation, :controller => 'mweb_events/events'
      get  :invite, :controller => 'mweb_events/events'
    end

    mount MwebEvents::Engine => '/'
  end

  # shibboleth controller
  get '/secure', :to => 'shibboleth#login', :as => "shibboleth"
  get '/secure/info', :to => 'shibboleth#info', :as => "shibboleth_info"
  post '/secure/associate', :to => 'shibboleth#create_association', :as => "shibboleth_create_association"

  # to crop images
  get "logo_images/crop", :to => 'logo_images#crop'

  resources :spaces do

    collection do
      get :select
    end

    member do
      post :enable
      post :update_logo
      delete :disable
      post :leave
      get :user_permissions
      get :webconference_options
      get :webconference
      get :recordings
    end

    get '/recordings/:id/edit', :to => 'spaces#edit_recording', :as => 'edit_recording'

    if Mconf::Modules.mod_loaded?('events')
      get '/events', :to => 'space_events#index', :as => 'events'
    end

    resources :users, :only => :index

    resources :news

    resources :join_requests do
      collection do
        get :invite
      end
    end

    resources :posts do
      member do
        get :reply_post
        post :spam_report, :action => :spam_report_create
      end
    end

    resources :attachments, :except => [:edit, :update]
    delete 'attachments', :to => 'attachments#delete_collection'
  end

  resources :permissions, :only => [:update, :destroy]

  resources :users, :except => [:new, :create] do

    collection do
      get :fellows
      get :select
      get :current
    end

    member do
      post :enable
      post :approve
      post :disapprove
    end

    resource :profile, :except => [:new, :create] do
      post :update_logo
    end
  end

  # Routes specific for the current user
  get '/home', :to => 'my#home', :as => 'my_home'
  get '/activity', :to => 'my#activity', :as => 'my_activity'
  get '/rooms', :to => 'my#rooms', :as => 'my_rooms'
  get '/room/edit', :to => 'my#edit_room', :as => 'edit_my_room'
  get '/recordings', :to => 'my#recordings', :as => 'my_recordings'
  get '/recordings/:id/edit', :to => 'my#edit_recording', :as => 'edit_my_recording'
  get '/approval_pending', :to => 'my#approval_pending', :as => 'my_approval_pending'

  resources :messages, :controller => :private_messages, :except => [:edit]

  resources :feedback do
    get :webconf, :on => :collection
  end

  # The unique Site is created in db/seeds and can only be edited
  resource :site, :only => [:show, :edit, :update]

  # Management routes
  ['users', 'spaces', 'spam'].each do |resource|
    get "/manage/#{resource}", :to => "manage##{resource}", :as => "manage_#{resource}"
  end

  # Locale controller, to change languages
  resource :language, :only => [:create], :controller => :session_locales, :as => :session_locale

  # General statistics for the website
  get '/statistics', :to => 'statistics#show', :as => 'show_statistics'

  # 'Hack' to show a custom 404 page.
  # See more at http://blog.igodigital.com/blog/notes-on-cyber-weekend-targeted-email-campaigns/custom-error-handling-in-rails-303
  # and http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
  unless Rails.application.config.consider_all_requests_local
    get '*not_found', :to => 'errors#error_404'
  end
end
