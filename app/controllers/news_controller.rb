# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class NewsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  load_and_authorize_resource :space, find_by: :permalink
  load_and_authorize_resource through: :space, instance_name: 'news', except: [:index]

  before_filter :webconf_room!, only: [:index]
  before_filter :get_news, only: [:index]

  after_filter only: [:create, :update] do
    @news.new_activity params[:action], current_user unless @news.errors.any?
  end

  rescue_from CanCan::AccessDenied, with: :handle_access_denied

  def create
    @news = @space.news.build(params[:news])

    if @news.save
      flash[:success] = t('news.created')
    else
      flash[:error] = t('news.error.create')
    end
    redirect_to request.referer
  end

  def index
    render layout: 'spaces_show'
  end

  def new
    render layout: false if request.xhr?
  end

  def show
  end

  def destroy
    if @news.destroy
      flash[:success] = t('news.deleted')
    else
      flash[:error] = t('news.error.delete')
    end
    redirect_to request.referer
  end

  def edit
    render layout: false if request.xhr?
  end

  def update
    if @news.update_attributes(params[:news])
      flash[:success] = t('news.updated')
    else
      flash[:error] = t('news.error.update')
    end
    redirect_to space_news_index_path(@space)
  end

  private

  def get_news
    @news = @space.news.order("updated_at DESC")
    authorize! :index_news, @space
  end

  def handle_access_denied exception
    if user_signed_in?
      render_403 exception
    else
      redirect_to login_path
    end
  end

end
