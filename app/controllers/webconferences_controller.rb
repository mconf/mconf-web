class WebconferencesController < ApplicationController
  before_filter :space!
  before_filter :webconf_room!

  authorization_filter [:create, :content ], :space, :only => [ :new, :create ]
  authorization_filter [:read, :content ],   :space, :only => [ :show, :index ]
  authorization_filter [:update, :content ], :space, :only => [ :edit, :update ]
  authorization_filter [:delete, :content ], :space, :only => [ :destroy ]

  layout 'spaces_show', :only => [:show]

  # def index
  #     if space.webconferences[0]
  #       @display_entry = space.webconferences[0];
  #     else
  #       @display_entry = nil
  #     end
  #   respond_to do |format|
  #     format.html
  #   end
  # end

  def show
    # FIXME Temporarily matching users by name, should use the userID
    @webconf_attendees = []
    unless @webconf_room.attendees.nil?
      @webconf_room.attendees.each do |attendee|
        profile = Profile.find(:all, :conditions => { "full_name" => attendee.full_name }).first
        unless profile.nil?
          @webconf_attendees << profile.user
        end
      end
    end

  end

end
