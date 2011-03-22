class WebconferencesController < ApplicationController
  before_filter :space!
  
  authorization_filter [:create, :content ], :space, :only => [ :new, :create ]
  authorization_filter [:read, :content ],   :space, :only => [ :show, :index ]
  authorization_filter [:update, :content ], :space, :only => [ :edit, :update ]
  authorization_filter [:delete, :content ], :space, :only => [ :destroy ]
  
  def index
      if space.webconferences[0]
        @display_entry = space.webconferences[0];
      else
        @display_entry = nil
      end 
   
    respond_to do |format|
      format.html
    end
  end  
  
  
  def show

    #TODO temporary implementation of a bbb room for this space
    unless BBB_API.is_meeting_running?(@space.name)
      BBB_API.create_meeting(@space.name, @space.name, "mp", "ap", "Welcome to Mconf!")
    end
    @bbb_info = {}
    @bbb_info[:room] = @space.name
    @bbb_info[:running] = BBB_API.is_meeting_running?(@space.name)
    @bbb_info[:info] = BBB_API.get_meeting_info(@space.name, "mp")
    @bbb_info[:link] = BBB_API.moderator_url(@space.name, current_user.name, "mp")
    @bbb_enabled = @space.actors.include?(current_user)

    @bbb_attendees = []
    node = @bbb_info[:info][:attendees][:attendee]
    if node.kind_of?(Array)
      node.each do |att|
        Profile.find(:all, :conditions => { "full_name" => att[:fullName] }).each do |profile|
          @bbb_attendees << profile.user
        end
      end
    elsif !node.nil?
      Profile.find(:all, :conditions => { "full_name" => node[:fullName] }).each do |profile|
        @bbb_attendees << profile.user
      end
    end
  end
   
end
