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

  def resources_for_join_requests controller
    singular = controller.to_s.singularize
    get  "#{controller}/:id/join_requests", :to => "#{controller}#join_request_index", :as => "#{singular}_join_requests"
    get  "#{controller}/:id/join_requests/new", :to => "#{controller}#join_request_new", :as => "new_#{singular}_join_request"
    post "#{controller}/:id/join_requests", :to => "#{controller}#join_request_create", :as => "create_#{singular}_join_request"
    put  "#{controller}/:id/join_requests/:jr_id", :to => "#{controller}#join_request_update", :as => "update_#{singular}_join_request"
  end

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
  match '/bigbluebutton/rooms/:id/join_options',
    :to => 'custom_bigbluebutton_rooms#join_options',
    :as => "join_options_bigbluebutton_room"
  # shortcut route to join webconference rooms
  match '/webconf/:id',
    :to => 'custom_bigbluebutton_rooms#invite_userid',
    :as => "join_webconf"

  # shibboleth controller
  match '/secure', :to => 'shibboleth#create', :as => "shibboleth"
  match '/secure/info', :to => 'shibboleth#info', :as => "shibboleth_info"

  resources :machines do
    collection do
      get :contact_mail
      get :my_mailer
    end
  end

  resources :spaces do

    bigbluebutton_routes :room_matchers # TODO: review
    match '/webconference' => 'webconferences#space_show'

    member do
      post :enable
      post :leave
      get :user_permissions
    end

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

  resources_for_join_requests :spaces

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
    end

    match '/webconference/edit' => 'webconferences#user_edit'

    resources :private_messages, :except => [:edit], :as => 'messages'
    resource :profile, :except => [:new, :create]

    resource :avatar do
      member do
        post :precrop
      end
    end
  end

  resource :home do
    member do
      get :user_rooms
      get :activity
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

  # Statistics
  match '/statistics', :to => 'statistics#show', :as => 'show_statistics'

  match 'get_file/:id', :to => 'machines#get_file', :as => 'get_file'

  # 'Hack' to show a custom 404 page.
  # See more at http://blog.igodigital.com/blog/notes-on-cyber-weekend-targeted-email-campaigns/custom-error-handling-in-rails-303
  # and http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages
  unless Rails.application.config.consider_all_requests_local
    match '*not_found', :to => 'errors#error_404'
  end
end
