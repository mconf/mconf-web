# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class NewsController < ApplicationController

  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :through => :space

  def create
    @news = News.new(params[:news])
    @news.space = @space

    respond_to do |format|
      if @news.save
        flash[:success] = t('news.created')
        format.html { redirect_to request.referer }

        @news.create_activity :create, :owner => @space,
          :parameters => { :user_id => current_user.id,
                           :username => current_user.name,
                           :name => @news.title
                         }

      else
        flash[:error] = t('news.error.create')
        format.html { redirect_to request.referer }
      end
    end
  end

  def index
    @news = @space.news.find(:all, :order => "updated_at DESC")
    @edit_news = @news.select{|n| n.id == params[:edit_news].to_i} if params[:edit_news]
     respond_to do |format|
      format.html{
      }
     end
  end

  def show
    @news = News.find(params[:id])
     respond_to do |format|
      format.html{
      }
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
    respond_to do |format|
      format.html {
        @edit_news = @space.news.find(params[:id])
        if request.xhr?
          render "edit_news_big", :layout => false
        else
          render "edit_news_big"
        end
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

      @news.create_activity :update, :owner => @space,
        :parameters => { :user_id => current_user.id,
                         :username => current_user.name,
                         :name => @news.title
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
        if request.xhr?
          render "create_news_big", :layout => false
        else
          render "create_news_big"
        end
      }
    end
  end
end
