# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class NewsController < ApplicationController
  
  before_filter :space, :only => [ :create, :index, :destroy, :edit, :update,:show, :new ]
  
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
