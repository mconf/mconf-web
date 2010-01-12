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

class SearchController < ApplicationController
  before_filter :space
  
  def all    
    search_events(params)
    search_users(params)
    search_posts(params)    
    search_attachments(params)
  end
  
  def attachments
    search_attachments(params)    
  end 
  
  def events
    search_events(params)
  end 
    
  def posts
    search_posts(params)
  end
  
  def users
    search_users(params)
  end
  
  def tag
    
    @tag = Tag.find_by_name(params[:tag])
    @users = @tag.taggings.all(:conditions => [ "taggable_type = ?", "User" ]).map{ |t| 
      User.find(t.taggable_id) 
    }

    @events = @tag.taggings.all(:conditions => [ "taggable_type = ?", "Event" ]).map{ |t| 
      Event.find(t.taggable_id) 
    }

    @posts = @tag.taggings.all(:conditions => [ "taggable_type = ?", "Post" ]).map{ |t| 
      Post.find(t.taggable_id)
    }
    @query = params[:tag]
    respond_to do |format|        
      format.html     
    end
  end
  
  
  private
  
  def authorize_read?(elements)
    elements.select{|e| e.is_a?(User) ?
                        e.authorize?([:read, :profile],:to=> current_user) :
                        e.authorize?(:read, :to => current_user)}
  end
  
  def search_events(params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}
    
    if params[:query]
      @query = params[:query]
      
    elsif params[:title]
      @query = filters[:name] = params[:title]
      
    elsif params[:description]
      @query = filters[:description] = params[:description]
     
   elsif (params[:time1] && params[:time2]) or (params[:start_date] && params[:end_date])
      date1ok = date2ok = 0
      @query = ""
      if (params[:time1] && params[:time2] && !params[:time1].blank? && !params[:time2].blank?)
        date1 = Date.civil(params[:time1][:year].to_i, params[:time1][:month].to_i, params[:time1][:day].to_i)
        date2 = Date.civil(params[:time2][:year].to_i, params[:time2][:month].to_i, params[:time2][:day].to_i)
        date1ok =  date1.strftime("%Y%m%d")
        date2ok =  date2.strftime("%Y%m%d")
        filters[:start_date] = date1.to_s..date2.to_s
        filters[:end_date] = date1.to_s..date2.to_s
      elsif params[:start_date] && params[:end_date] && !params[:start_date].blank? && !params[:end_date].blank?
        date1 = params[:start_date].to_date
        date2 = params[:end_date].to_date
        date1ok =  date1.strftime("%Y%m%d")
        date2ok =  date2.strftime("%Y%m%d")
        filters[:start_date] = date1.to_s..date2.to_s
        filters[:end_date] = date1.to_s..date2.to_s
      end  
      if date1ok > date2ok
        flash[:notice] = t('event.error.dates')
        render :template => "events/search"
      end
    end
    
    @search = Ultrasphinx::Search.new(:query => params[:query],:class_names => 'Event',:filters => filters)
    @search.run

    @events = @space.nil? ? authorize_read?(@search.results) : @search.results 
  end
  
  def search_posts (params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}
    
    @query = params[:query] 
    @search = Ultrasphinx::Search.new(:query => @query,  :per_page => 1000000, :class_names => 'Post', :filters => filters)
    @search.run
    posts = @space.nil? ? authorize_read?(@search.results) : @search.results
    posts = posts.sort{
            |x,y| ((y.parent_id != nil) ? y.parent.updated_at : y.updated_at) <=> ((x.parent_id != nil) ? x.parent.updated_at : x.updated_at)
          }
    @posts = posts.paginate(:page => params[:page],:per_page => 5)
    @number_of_posts = posts.size                  
  end
  
  def search_users (params)
    @query = params[:query]
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'User')
    @search.run
    @users = @space.nil? ?
              authorize_read?(@search.results) :
              @search.results.select {|user| @space.actors.include?(user)}
  end
  
  def search_attachments (params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}
    
    @query = params[:query] 
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'Attachment', :filters => filters)
    @search.run
    @attachments = @space.nil? ? authorize_read?(@search.results) : @search.results
  end
end

