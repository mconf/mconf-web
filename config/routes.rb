# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# The priority is based upon order of creation:
# first created -> highest priority.
#
# Sample of regular route:
#   match 'products/:id', to: 'catalog#view'
# Keep in mind you can assign values other than :controller and :action
#
# Sample of named route:
#   match 'products/:id/purchase', to: 'catalog#purchase', as: :purchase
# This route can be invoked with purchase_url(id: product.id)
#
# See how all your routes lay out with "rake routes"

Mconf::Application.routes.draw do
  frontpage = Rails.application.config.external_frontpage
  root to: frontpage.blank? ? 'frontpage#show' : redirect(frontpage)

  # devise
  controllers = { sessions: "sessions", registrations: "registrations",
                  passwords: "passwords", confirmations: "confirmations",
                  omniauth_callbacks: "callbacks" }
  paths = { sign_in: "login", sign_out: "logout", sign_up: "signup", registration: "registration" }
  devise_for :users, paths: "", path_names: paths, controllers: controllers
  devise_scope :user do
    get "login", to: "sessions#new"
    get "logout", to: "sessions#destroy"
    get "register", to: "registrations#new"

    # so admins can log in even if local auth is disabled
    get '/manage/login', to: 'sessions#new', as: 'admin_login'
  end
  get '/guest/logout', to: 'application#logout_guest_action', as: 'logout_guest'

  # conference routes
  # bigbluebutton_rails gem
  conf_scope = Rails.application.config.conf_scope
  conf_controllers = {
    servers: 'custom_bigbluebutton_servers',
    rooms: 'custom_bigbluebutton_rooms',
    recordings: 'custom_bigbluebutton_recordings',
    playback_types: 'custom_bigbluebutton_playback_types'
  }
  bigbluebutton_routes :default, scope: conf_scope, as: 'bigbluebutton', controllers: conf_controllers
  bigbluebutton_api_routes

  # register a few custom routes that were added to bigbluebutton_rails
  get "/#{conf_scope}/rooms/:id/invitation",
    to: 'custom_bigbluebutton_rooms#invitation',
    as: "invitation_bigbluebutton_room"
  post "/#{conf_scope}/rooms/:id/send_invitation",
    to: 'custom_bigbluebutton_rooms#send_invitation',
    as: "send_invitation_bigbluebutton_room"
  get "/#{conf_scope}/rooms/:id/user_edit",
    to: 'custom_bigbluebutton_rooms#user_edit',
    as: "user_edit_bigbluebutton_room"
  get "/#{conf_scope}/playback_types",
    to: 'custom_bigbluebutton_playback_types#index',
    as: "bigbluebutton_playback_types"

  # note: this block *has* to be before `resources :users`, otherwise some
  # routes here won't work well
  scope 'users' do
    get 'pending', to: 'my#approval_pending', as: 'my_approval_pending'

    # login via Shibboleth
    scope 'shibboleth' do
      get '/', to: 'shibboleth#login', as: "shibboleth"
      get 'info', to: 'shibboleth#info', as: "shibboleth_info"
      post 'associate', to: 'shibboleth#create_association', as: "shibboleth_create_association"
    end

    # login via certificate
    get 'certificate', to: 'certificate_authentication#login', as: 'certificate_login'
  end
  # to keep it compatible with previous versions (i.e. if apache is configured for '/secure')
  get 'secure', to: redirect('/users/shibboleth')

  resources :users, except: [:index] do
    collection do
      get :fellows
      get :select
      get :current
    end

    member do
      delete :disable
      post :enable
      post :approve
      post :disapprove
      post :confirm
      post :update_logo
    end
  end


  # routes specific for the current user
  scope 'home' do
    get '/', to: 'my#home', as: 'my_home'
    get 'activity', to: 'my#activity', as: 'my_activity'
    get 'meetings', to: 'my#meetings', as: 'my_meetings'
    get 'recordings/:id/edit', to: 'my#edit_recording', as: 'edit_my_recording'
  end

  resources :spaces do
    collection do
      get :select
    end

    member do
      post :enable
      post :update_logo
      delete :disable
      post :leave
      post :approve
      post :disapprove
      get :user_permissions
      get :webconference
      get :meetings
    end

    get '/recordings/:id/edit', to: 'spaces#edit_recording', as: 'edit_recording'

    get '/events', to: 'space_events#index', as: 'events'
    get '/events/new', to: 'events#new', as: 'new_event'

    resources :users, only: :index

    resources :join_requests, only: [:new, :create] do
      collection do
        get :admissions
        get :invite
      end

      member do
        post :accept
        post :decline
      end
    end

    resources :posts do
      member do
        get :reply_post
      end
    end

    resources :attachments, except: [:edit, :update]
    delete 'attachments', to: 'attachments#delete_collection'
  end

  scope 'manage' do
    resource :site, only: [:show, :edit, :update]

    ['users', 'spaces', 'recordings', 'statistics', 'statistics_filter', 'statistics_csv'].each do |resource|
      get resource, to: "manage##{resource}", as: "manage_#{resource}"
    end

    get '/', to: redirect('/manage/site'), as: 'manage'
  end

  constraints CanAccessResque do
    mount Resque::Server, at: 'manage/resque'
  end

  resources :events do
    collection do
      get :select
      get 'participants/confirmations/:token', to: 'participant_confirmations#confirm', as: 'participant_confirmation'
      get 'participants/confirmations/:token/cancel', to: 'participant_confirmations#destroy', as: 'cancel_participant_confirmation'
    end

    member do
      post :send_invitation
      get  :invite
    end

    resources :participants, except: [:show, :edit]
  end

  post 'language/:lang', to: 'session_locales#create', language: /#{I18n.available_locales.join("|")}/, as: :session_locale
  get 'language/:lang', to: 'session_locales#create', language: /#{I18n.available_locales.join("|")}/

  resources :feedback, only: [:new, :create] do
    get :webconf, on: :collection
  end

  resources :permissions, only: [:update, :destroy]

  get "tags/select", to: 'tags#select'

  # to crop images
  get "logos/crop", to: 'logo_images#crop', as: 'logo_images_crop'

  # To treat errors on pages that don't fall on any other controller
  match ':status', to: 'errors#on_error', constraints: { status: /\d{3}/ }, via: :all

  # shortcut route to join webconference rooms
  # note: has to be left as the last route in case no scope is used!
  get "/#{Rails.application.config.conf_scope_rooms}/:id",
      to: 'custom_bigbluebutton_rooms#invite_userid',
      as: "join_webconf"
end
