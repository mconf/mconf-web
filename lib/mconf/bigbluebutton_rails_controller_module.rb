module Mconf::BigbluebuttonRailsControllerModule

  # overriding bigbluebutton_rails function
  def bigbluebutton_user
    if current_user && current_user.is_a?(User)
      current_user
    elsif current_guest_user
      current_guest_user
    else
      nil
    end
  end

  def bigbluebutton_role(room)
    if BigbluebuttonRails.configuration.guest_support
      guest_role = :guest
    else
      guest_role = :attendee
    end

    # first make sure the room has a valid owner
    if room.owner_type == "User"
      user = User.find_by(id: room.owner_id)
      return nil if user.nil? || user.disabled
    elsif room.owner_type == "Space"
      space = Space.find_by(id: room.owner_id)
      return nil if space.nil? || space.disabled
    else
      return nil
    end

    if current_user.nil?
      # anonymous users
      if room.private?
        :key
      else
        guest_role
      end
    else
      # Superusers has the right to create and be moderator in any room
      if current_user.superuser?
        :moderator
      elsif room.owner_type == "User"
        if room.owner.id == current_user.id
          # only the owner is moderator
          :moderator
        else
          if room.private
            :key # ask for a password if room is private
          else
            guest_role
          end
        end
      elsif room.owner_type == "Space"
        space = Space.find(room.owner.id)
        if space.admins.include?(current_user)
          :moderator
        elsif space.users.include?(current_user)
          # will be moderator if he's creating a new meeting or he already created it
          if !room.is_running? || room.user_created_meeting?(current_user)
            :moderator
          else
            :attendee
          end
        else
          if room.private
            :key
          else
            guest_role
          end
        end
      end
    end
  end

  # This method is called from BigbluebuttonRails.
  # Returns whether the current user can create a meeting in 'room'.
  def bigbluebutton_can_create?(room, role)
    ability = Abilities.ability_for(current_user)
    ability.can?(:create_meeting, room)
  end

  # loads the web conference room for the current space into `@webconf_room` and fetches information
  # about it from the web conference server (`getMeetingInfo`)
  def webconf_room!
    @webconf_room = @space.bigbluebutton_room
    if @webconf_room
      begin
        @webconf_room.fetch_meeting_info
      rescue Exception
      end
    else
      raise(ActiveRecord::RecordNotFound)
    end

    @webconf_room
  end

end
