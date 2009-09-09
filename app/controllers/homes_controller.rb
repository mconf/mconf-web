class HomesController < ApplicationController
  def index
  end

  
  def show
    all_events = []
    all_users = []
    all_posts = []
    all_news = []
    @today_events = []
    @tomorrow_events = []
    @week_events = []
    @upcoming_events = []
    for space in current_user.spaces do
      all_events += space.events.find(:all, :order => "updated_at DESC", :limit => 5)
      #all_users += space.actors.sort{|x,y| y.created_at <=> x.created_at }.first(5)
      all_posts += space.posts.not_events().find(:all, :conditions => {"parent_id" => nil}, :order => "updated_at DESC", :limit => 10)
      all_news += space.news.find(:all, :order => "updated_at DESC", :limit => 5)
      #for the upcoming events, I take those that end in the future, so that includes the events being accomplished now
      #upcoming_events += space.events.find(:all, :conditions => {"start_date" > Date.now}, :order => "start_date DESC", :limit => 2)
      @today_events += space.events.find(:all, :conditions => ["start_date > :now_date AND start_date < :tomorrow", 
        {:now_date=> Time.now, :tomorrow => Date.tomorrow}], :order => "start_date DESC")
      @tomorrow_events += space.events.find(:all, :conditions => ["start_date > :tomorrow AND start_date < :day_after_tomorrow", 
        {:day_after_tomorrow=> Date.tomorrow + 1.day, :tomorrow => Date.tomorrow}], :order => "start_date DESC")
      @week_events += space.events.find(:all, :conditions => ["start_date > :day_after_tomorrow AND start_date < :one_week_more", 
        {:day_after_tomorrow=> Date.tomorrow + 1.day, :one_week_more => Date.tomorrow+7.days}], :order => "start_date DESC", :limit => 2)
      @upcoming_events += space.events.find(:all, :conditions => ["start_date > :one_week_more AND start_date < :one_month_more", 
        {:one_week_more => Date.tomorrow+7.days, :one_month_more => Date.tomorrow+37.days}], :order => "start_date DESC", :limit => 2)
    end
    
    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
    
    #remove repeated users 
    #all_users.uniq!
    #join all three arrays
    @all_in_all = []
    @all_in_all += all_events + all_users + all_posts + all_news
    #sort the array with the updated_at date
    @all_in_all.sort!{|x,y| y.updated_at <=> x.updated_at}
    @today = @all_in_all.select{|x| x.updated_at > Date.yesterday}
    @yesterday = @all_in_all.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}
    @last_week = @all_in_all.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}
    @older = @all_in_all.select{|x| x.updated_at < Date.today - 7}
    
    

    
    @all_in_all = @all_in_all.paginate(:page=>params[:page], :per_page=>15)
    #debugger
  end
end
