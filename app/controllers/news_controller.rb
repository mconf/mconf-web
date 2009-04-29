class NewsController < ApplicationController
  
  before_filter :space, :only => [ :create, :index ]
  
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
  end
  
end
