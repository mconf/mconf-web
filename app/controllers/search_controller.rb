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
  authorization_filter [ :read, :content ], :space, :if => :space
  
  def index

    params[:query] ||= ""
    
    # Delete '-' from the query
    @query = params[:query].gsub("-"," ")
    # Surround words with '*' unless it also has '*' or '"'
    @query = (@query.include?('*') || @query.include?('\"')) ? @query : @query.split.map{|s| "*#{s}*"}.join(' ')

      
    if params[:start_date].blank? && params[:end_date].blank? && params[:query].blank?
    elsif params[:start_date].blank? && params[:end_date].blank? && params[:query].length < 3
      flash[:notice] = t('search.parameters')
    else
      case params[:type]
        when "spaces"
          search_spaces(params)
        when "events"
          search_events(params)
        when "videos"
          search_videos(params)
        when "posts"
          search_posts(params)
        when "attachments"
          search_attachments(params)
        when "users"
          search_users(params)
        else
          search_spaces(params) if @space.nil?
          search_events(params)
          search_videos(params)
          search_users(params)
          search_posts(params)    
          search_attachments(params)
      end
    end    

    respond_to do |format|
      format.html
      format.rss
    end
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
    elements.select{|e| e.authorize?(:read, :to => current_user)}
  end
  
  def search_spaces (params)
    @search = Ultrasphinx::Search.new(:query => @query,  :per_page => 1000000, :class_names => 'Space')
    @search.run
    
    @spaces = authorize_read?(@search.results)
  end
  
  def search_events(params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}
    
    #FIXME Improve searches to find any event in the range, now it searches any event that starts in the range
    filter_date(params, filters, [:start_date])
    
    @search = Ultrasphinx::Search.new(:query => @query,:class_names => 'Event',:filters => filters, :sort_mode => 'descending', :sort_by => 'start_date')
    @search.run

    @events = @space.nil? ? authorize_read?(filter_from_disabled_spaces(@search.results)) : @search.results
    
    #Include events from the agenda entries.
    @events = (@events + (@agenda_entries || search_agenda_entries(params)).map{|ae| ae.event}).uniq
  end
  
  def search_agenda_entries(params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}
    
    filter_date(params, filters, [:start_time, :end_time])
    
    @search = Ultrasphinx::Search.new(:query => @query,:class_names => 'AgendaEntry',:filters => filters, :sort_mode => 'descending', :sort_by => 'start_time')
    @search.run

    @agenda_entries = @space.nil? ? authorize_read?(filter_from_disabled_spaces(@search.results)) : @search.results 
  end
  
  def search_videos(params)
    @videos = (@agenda_entries || search_agenda_entries(params)).select(&:recording?)
  end
  
  def search_posts (params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}    
    
    filter_date(params, filters, [:updated_at])
    
    @search = Ultrasphinx::Search.new(:query => @query,  :per_page => 1000000, :class_names => 'Post', :filters => filters)
    @search.run
    @posts = @space.nil? ? authorize_read?(filter_from_disabled_spaces(@search.results)) : @search.results
    @posts = @posts.sort{
            |x,y| ((y.parent_id != nil) ? y.parent.updated_at : y.updated_at) <=> ((x.parent_id != nil) ? x.parent.updated_at : x.updated_at)
          }                
  end
  
  def search_users (params)
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'User')
    @search.run
    @users = @space.nil? ?
              authorize_read?(@search.results) :
              @search.results.select {|user| @space.actors.include?(user)}
  end
  
  def search_attachments (params)
    filters = @space.nil? ? {} : {'space_id' => @space.id}
    
    filter_date(params, filters, [:updated_at])
    
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'Attachment', :filters => filters, :sort_mode => 'descending', :sort_by => 'updated_at')
    @search.run
    @attachments = @space.nil? ? authorize_read?(filter_from_disabled_spaces(@search.results)) : @search.results
  end
  
  def filter_date(params, filters, values)
    if params[:start_date] && params[:end_date] && !params[:start_date].blank? && !params[:end_date].blank?
      start_date = params[:start_date].to_time
      end_date = (params[:end_date] + " 23:59:59").to_time
      if start_date > end_date
        flash[:notice] = t('event.error.dates')
      else
        values.each do |value|        
          filters[value] = start_date..end_date
        end
      end        
    end
  end
  
  def filter_from_disabled_spaces elements
    elements.select{|e| !e.space.disabled?}
  end
end

