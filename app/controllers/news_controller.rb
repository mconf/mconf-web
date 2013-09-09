# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class NewsController < ApplicationController

  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :through => :space

  after_filter :only => [:create, :update] do
    @news.new_activity params[:action], current_user unless @news.errors.any?
  end

  def create
    @news = @space.news.build(params[:news])

    respond_to do |format|
      if @news.save
        flash[:success] = t('news.created')
        format.html { redirect_to request.referer }
      else
        flash[:error] = t('news.error.create')
        format.html { redirect_to request.referer }
      end
    end
  end

  def index
    @all_news = @space.news.order("updated_at DESC")
    @news = @space.news.new

    respond_to do |format|
       format.html {}
    end
  end

  def show
    @news = @space.news.find(params[:id])

    respond_to do |format|
      format.html {}
    end
  end

  def destroy
    news = @space.news.find(params[:id])

    if news.destroy

      respond_to do |format|
        format.html {
          flash[:success] = t('news.deleted')
          redirect_to request.referer
        }
      end
    else
      flash[:error] = t('news.error.delete')
      redirect_to request.referer
    end
  end

  def edit
    @news = @space.news.find(params[:id])
    respond_to do |format|
      format.html {
        render :layout => false if request.xhr?
      }
    end
  end

  def update
    @news = @space.news.find(params[:id])

    if @news.update_attributes(params[:news])
      respond_to do |format|
        format.html {
          flash[:success] = t('news.updated')
          redirect_to space_news_index_path(@space)
        }
      end
    else
      flash[:error] = t('news.error.update')
      redirect_to space_news_index_path(@space)
    end
  end

  def new
      respond_to do |format|
        format.html {
          render :layout => false if request.xhr?
        }
      end
  end

end
