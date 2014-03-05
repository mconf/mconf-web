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

  match "logo_images/crop", :to => 'logo_images#crop'

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
  bigbluebutton_routes :default, :controllers => {
    :servers => 'custom_bigbluebutton_servers',
    :rooms => 'custom_bigbluebutton_rooms',
    :recordings => 'custom_bigbluebutton_recordings'
  }
  # register a few custom routes that were added to this controller
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

  # shibboleth controller
  match '/secure', :to => 'shibboleth#login', :as => "shibboleth"
  match '/secure/info', :to => 'shibboleth#info', :as => "shibboleth_info"
  post '/secure/associate', :to => 'shibboleth#create_association', :as => "shibboleth_create_association"

  resources :spaces do

    collection do
      get :select
    end

    resources :join_requests do
      collection do
        get :invite
      end
    end

    bigbluebutton_routes :room_matchers # TODO: review

    member do
      post :enable
      post :leave
      get :user_permissions
      get :webconference_options
      get :webconference
      get :recordings
    end
    match '/recordings/:id/edit', :to => 'spaces#edit_recording', :as => 'edit_recording'

    resources :users do # TODO: do we really need this?
      resource :profile, :except => [:new, :create]
    end

    resources :readers

    resources :events do

      member do
        post :spam_report, :action => :spam_report_create
      end

      collection do
        get :add_time
        get :copy_next_week
        get :remove_time
      end

      resources :participants
    end

    resources :posts do
      member do
        get :reply_post
        post :spam_report, :action => :spam_report_create
      end
    end

    delete 'attachments', :to => 'attachments#delete_collection', :as => 'attachments'

    resources :attachments do
      member do
        get :edit_tags
      end
    end

    resources :entries

    resources :news
  end

  resources :permissions
  resources :memberships

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

    resource :profile, :except => [:new, :create]
  end

  # Routes specific for the current user
  match '/home', :to => 'my#home', :as => 'my_home'
  match '/activity', :to => 'my#activity', :as => 'my_activity'
  match '/rooms', :to => 'my#rooms', :as => 'my_rooms'
  match '/room/edit', :to => 'my#edit_room', :as => 'edit_my_room'
  match '/recordings', :to => 'my#recordings', :as => 'my_recordings'
  match '/recordings/:id/edit', :to => 'my#edit_recording', :as => 'edit_my_recording'

  resources :messages, :controller => :private_messages, :except => [:edit]

  resources :feedback do
    collection do
      get :webconf
    end
  end

  resources :tags

  # The unique Site is created in db/seeds and can only be edited
  resource :site, :only => [:show, :edit, :update]

  # Management routes
  ['users', 'spaces', 'spam'].each do |resource|
    match "/manage/#{resource}", :to => "manage##{resource}", :as => "manage_#{resource}"
  end

  # Locale controller (globalize)
  resource :session_locale
  match ':locale/:controller/:action/:id'
  match 'locale/set/:id', :to => 'locale#set', :as => 'set'

  # root
  root :to => 'frontpage#show'

  # Statistics
  match '/statistics', :to => 'statistics#show', :as => 'show_statistics'

  # 'Hack' to show a custom 404 page.
  # See more at http://blog.igodigital.com/blog/notes-on-cyber-weekend-targeted-email-campaigns/custom-error-handling-in-rails-303
  # and http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
  unless Rails.application.config.consider_all_requests_local
    match '*not_found', :to => 'errors#error_404'
  end
end
