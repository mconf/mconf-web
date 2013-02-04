class WebconferencesController < ApplicationController
  before_filter :space!, :except => :join

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
    @room = @space.bigbluebutton_room
    @recordings = @room.recordings.published().order("end_time DESC").last(5)
    begin
      @room.fetch_meeting_info
    rescue Exception
    end

    # FIXME Temporarily matching users by name, should use the userID
    @bbb_attendees = []
    unless @room.attendees.nil?
      @room.attendees.each do |attendee|
        profile = Profile.find(:all, :conditions => { "full_name" => attendee.full_name }).first
        unless profile.nil?
          @bbb_attendees << profile.user
        end
      end
    end
  end

end
