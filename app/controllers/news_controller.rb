# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class NewsController < ApplicationController
  load_and_authorize_resource :space
  load_and_authorize_resource :through => :space

  def create
    @news = News.new(params[:news])
    @news.space = @space

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
    @news = @space.news.find(:all, :order => "updated_at DESC")
    @edit_news = @news.select{|n| n.id == params[:edit_news].to_i} if params[:edit_news]
     respond_to do |format|
      format.html{
      }
      format.atom
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
        if params[:big]
          @edit_news = @space.news.find(params[:id])
          if request.xhr?
            render "edit_news_big", :layout => false
          else
            render "edit_news_big"
          end
        else
          if request.xhr?
            @edit_news = @space.news.find(params[:id])
            render :partial => 'edit_news'
          else
            redirect_to space_news_index_path(@space, :edit_news => params[:id])
          end
        end
      }
      format.js {
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
        if request.xhr?
          render "create_news_big", :layout => false
        else
          render "create_news_big"
        end
      }
    end
  end
end
