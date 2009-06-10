class NewsController < ApplicationController
  
  before_filter :space, :only => [ :create, :index, :destroy, :edit, :update ]
  
  def create
    @new = News.new(params[:new])
    @new.space = @space

    respond_to do |format|
      if @new.save
        flash[:success] = 'New was successfully published.'
        format.html { redirect_to request.referer }
      else
        flash[:error] = 'There was a problem publishing news.'
        format.html { redirect_to request.referer }
      end
    end
  end
  
  def index 
    @news = @space.news.find(:all, :order => "updated_at DESC")
    @edit_news = @news.select{|n| n.id == params[:edit_news].to_i} if params[:edit_news]
  end
  
  def destroy
    news = @space.news.find(params[:id])
    if news.destroy
    respond_to do |format|
      format.html {
        flash[:success] = "Item successfully deleted"
        redirect_to request.referer
      }
      end
    else
      flash[:error] = "Error deleting item"
      redirect_to request.referer
    end
  end
  
  def edit
    respond_to do |format|
      format.html {
        if request.xhr?
          @edit_news = @space.news.find(params[:id])
          render :partial => 'edit_news' 
        else
          redirect_to space_news_index_path(@space, :edit_news => params[:id])  
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
      flash[:success] = "Item successfully updated"
        redirect_to space_news_index_path(@space)
      }
      end
    else
      flash[:error] = "Item could not be updated"
      redirect_to space_news_index_path(@space)
    end
  end
  
end
