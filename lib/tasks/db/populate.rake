require 'devise/encryptors/station_encryptor'

namespace :db do

  desc "Populate the DB with random test data. Options: SINCE, CLEAR"
  task :populate => :environment do
    # can't require at the top because will raise errors when running rake in
    # production (cannot load such file -- populator)
    require 'populator'

    reserved_usernames = ['lfzawacki', 'daronco', 'fbottin']

    @created_at_start = 1.year.ago
    @created_at_start_months = 12

    puts
    puts "*** Start date set to: #{@created_at_start}"

    username_offset = 0 # to prevent duplicated usernames

    if ENV['CLEAR']
      puts "*** Destroying all resources!"
      PrivateMessage.destroy_all
      Permission.destroy_all
      Space.destroy_all
      if configatron.modules.events.enabled
        MwebEvents::Event.destroy_all
        MwebEvents::Participant.destroy_all
      end
      RecentActivity.destroy_all
      User.with_disabled.where.not(id: User.first.id).destroy_all
      BigbluebuttonRoom.where.not(owner: User.first).destroy_all
      BigbluebuttonPlaybackType.destroy_all
      BigbluebuttonRecording.destroy_all
    end

    puts
    puts "* Create users (15)"
    User.populate 15 do |user|

      if username_offset < reserved_usernames.size # Use some fixed usernames and always approve them
        user.username = reserved_usernames[username_offset]
        user.approved = true
        puts "* Create users: default user '#{user.username}'"
      else # Create user as normal
        user.username = "#{Populator.words(1)}-#{username_offset}"
        user.approved = rand(0) < 0.8 # ~20% marked as not approved
      end
      username_offset += 1

      user.email = Forgery::Internet.email_address
      user.confirmed_at = @created_at_start..Time.now
      user.disabled = false
      user.encrypted_password = "123"

      Profile.create do |profile|
        profile.user_id = user.id
        profile.full_name = Forgery::Name.full_name
        profile.organization = Populator.words(1..3).titleize
        profile.phone = Forgery::Address.phone
        profile.mobile = Forgery::Address.phone
        profile.fax = Forgery::Address.phone
        profile.address = Forgery::Address.street_address
        profile.city = Forgery::Address.city
        profile.zipcode = Forgery::Address.zip
        profile.province = Forgery::Address.state
        profile.country = Forgery::Address.country
        profile.prefix_key = Forgery::Name.title
        profile.description = Populator.sentences(1..3)
        profile.url = "http://" + Forgery::Internet.domain_name + "/" + Populator.words(1)
        profile.skype = Populator.words(1)
        profile.im = Forgery::Internet.email_address
        profile.visibility = Populator.value_in_range((Profile::VISIBILITY.index(:everybody))..(Profile::VISIBILITY.index(:nobody)))
      end
    end

    User.find_each do |user|
      if user.bigbluebutton_room.nil?
        user.create_bigbluebutton_room :owner => user,
                                       :server => BigbluebuttonServer.default,
                                       :param => user.username,
                                       :name => user.full_name
      end
      # set the password this way so that devise makes the encryption
      unless user == User.first # except for the admin
        pass = "123456"
        user.update_attributes(:password => pass, :password_confirmation => pass)
      end
    end

    puts "* Create private messages"
    User.all.each do |user|
      senders = User.ids - [user.id]

      PrivateMessage.populate 5 do |message|
        message.receiver_id = user.id
        message.sender_id = senders
        message.title = Populator.words(1..3).capitalize
        message.body = Populator.sentences(1..3)
        message.checked = [ true, false ]
        message.deleted_by_sender = false
        message.deleted_by_receiver = false
        message.created_at = @created_at_start..Time.now
        message.updated_at = message.created_at..Time.now
      end
    end

    puts "* Create spaces (10)"
    Space.populate 10 do |space|
      begin
        name = Populator.words(1..3).capitalize
      end until Space.find_by(name: name).nil? and name.length >= 3
      space.name = name
      space.description = Populator.sentences(1..3)
      space.public = [ true, false ]
      space.disabled = false
      space.approved = true
      space.permalink = name.parameterize
      space.repository = [ true, false ]

      Post.populate 10..50 do |post|
        post.space_id = space.id
        post.title = Populator.words(1..4).titleize
        post.text = Populator.sentences(3..15)
        post.spam = false
        post.created_at = @created_at_start..Time.now
        post.updated_at = post.created_at..Time.now
        post.spam = rand(0) > 0.9 # ~10% marked as spam
      end

      News.populate 2..10 do |news|
        news.space_id = space.id
        news.title = Populator.words(3..8).titleize
        news.text = Populator.sentences(2..10)
        news.created_at = @created_at_start..Time.now
        news.updated_at = news.created_at..Time.now
      end
    end

    puts "* Create spaces: webconference rooms"
    Space.all.each do |space|
      if space.bigbluebutton_room.nil?
        BigbluebuttonRoom.create do |room|
          room.server_id = BigbluebuttonServer.default.id
          room.owner_id = space.id
          room.owner_type = 'Space'
          room.name = space.name
          room.meetingid = "#{SecureRandom.hex(16)}-#{Time.now.to_i}"
          room.attendee_key = "ap"
          room.moderator_key = "mp"
          room.private = !space.public
          room.logout_url = "/feedback/webconf"
          room.external = false
          room.param = space.name.parameterize.downcase
          room.duration = 0
          room.record_meeting = false
        end
      end
    end

    puts "* Create spaces: adding users"
    Space.all.each do |space|
      role_ids = Role.where(stage_type: 'Space').ids
      available_users = User.all.to_a

      puts "* Create spaces: \"#{space.name}\" - add first admin"
      Permission.create do |permission|
        user = available_users.sample
        available_users -= [user]
        permission.user_id = user.id
        permission.subject_id = space.id
        permission.subject_type = 'Space'
        permission.role_id = Role.where(name: 'Admin', stage_type: 'Space').first.id
        permission.created_at = user.created_at
        permission.updated_at = permission.created_at
      end

      puts "* Create spaces: \"#{space.name}\" - add more users (3..10)"
      Permission.populate 3..10 do |permission|
        user = available_users.sample
        available_users -= [user]
        permission.user_id = user.id
        permission.subject_id = space.id
        permission.subject_type = 'Space'
        permission.role_id = role_ids
        permission.created_at = user.created_at
        permission.updated_at = permission.created_at
      end
    end

    if configatron.modules.events.enabled
      puts "* Create events"

      puts "* Create events: for spaces (20..40)"
      available_spaces = Space.all.to_a
      MwebEvents::Event.populate 20..40 do |event|
        event.owner_id = available_spaces
        event.owner_type = 'Space'
        event.name = Populator.words(1..3).titleize
        event.permalink = Populator.words(1..3).split.join('-')
        event.time_zone = Forgery::Time.zone
        event.location = Populator.words(1..3)
        event.address = Forgery::Address.street_address
        event.description = Populator.sentences(20)
        event.summary = Populator.sentences(2)
        event.location = Populator.sentences(1)
        event.created_at = @created_at_start..Time.now
        event.updated_at = event.created_at..Time.now
        event.start_on = event.created_at..1.years.since(Time.now)
        event.end_on = 2.hours.since(event.start_on)..2.days.since(event.start_on)
      end

      puts "* Create events: for users (20..40)"
      available_users = User.all.to_a
      MwebEvents::Event.populate 20..40 do |event|
        event.owner_id = available_users
        event.owner_type = 'Space'
        event.name = Populator.words(1..3).titleize
        event.permalink = Populator.words(1..3).split.join('-')
        event.time_zone = Forgery::Time.zone
        event.location = Populator.words(1..3)
        event.address = Forgery::Address.street_address
        event.description = Populator.sentences(20)
        event.summary = Populator.sentences(2)
        event.location = Populator.sentences(1)
        event.created_at = @created_at_start..Time.now
        event.updated_at = event.created_at..Time.now
        event.start_on = event.created_at..1.years.since(Time.now)
        event.end_on = 2.hours.since(event.start_on)..2.days.since(event.start_on)
      end

      # TODO: #1115, populate with models from MwebEvents
      # if configatron.modules.events.loaded
      # puts "* Create spaces: \"#{space.name}\" - add users for events"
      # event_role_ids = Role.find_all_by_stage_type('Event').map(&:id)
      # space.events.each do |event|
      #   available_event_participants = space.users.dup
      #   Participant.populate 0..space.users.count do |participant|
      #     participant_aux = available_event_participants.delete_at((rand * available_event_participants.size).to_i)
      #     participant.user_id = participant_aux.id
      #     participant.email = participant_aux.email
      #     participant.event_id = event.id
      #     participant.created_at = event.created_at..Time.now
      #     participant.updated_at = participant.created_at..Time.now
      #     participant.attend = (rand(0) > 0.5)

      #     Permission.populate 1 do |permission|
      #       permission.user_id = participant.user_id
      #       permission.subject_id = event.id
      #       permission.subject_type = 'Event'
      #       permission.role_id = event_role_ids
      #       permission.created_at = participant.created_at
      #       permission.updated_at = permission.created_at
      #     end
      #   end
      # end
      # end
    end

    puts "* Create recordings and metadata for all webconference rooms (#{BigbluebuttonRoom.count} rooms)"

    # Playback types
    ids = ["presentation", "presentation_video", "presentation_export"]
    ids.each_with_index do |id, i|
      params = {
        identifier: id,
        visible: i==0 ? true : [true, false],
        default: i==0
      }
      BigbluebuttonPlaybackType.create(params)
    end

    BigbluebuttonRoom.all.each do |room|

      BigbluebuttonRecording.populate 2..10 do |recording|
        recording.room_id = room.id
        recording.server_id = room.server.id
        recording.recordid = "rec-#{SecureRandom.hex(16)}-#{Time.now.to_i}"
        recording.meetingid = room.meetingid
        recording.name = Populator.words(3..5).titleize
        recording.published = true
        recording.available = true
        recording.start_time = @created_at_start..Time.now
        recording.end_time = recording.start_time + rand(5).hours
        recording.description = Populator.words(5..8)

        # Recording metadata
        BigbluebuttonMetadata.populate 0..3 do |meta|
          meta.owner_id = recording.id
          meta.owner_type = recording.class.to_s
          meta.name = "#{Populator.words(1)}-#{meta.id}"
          meta.content = Populator.words(2..8)
        end

        # Recording playback formats
        # Note: make a few recordings without playback formats, meaning that the recording is still
        # being processed
        playback_types = BigbluebuttonPlaybackType.pluck(:id)
        BigbluebuttonPlaybackFormat.populate 0..3 do |format|
          format.recording_id = recording.id
          format.url = "http://#{Forgery::Internet.domain_name}/playback/#{Populator.words(1)}"
          format.length = Populator.value_in_range(32..128)

          id = playback_types.sample
          playback_types.delete(id)
          format.playback_type_id = id
        end
      end

      # Basic metadata needed in all recordings
      room.recordings.each do |recording|
        # this is created by BigbluebuttonRails normally
        user_id = recording.metadata.where(:name => BigbluebuttonRails.metadata_user_id.to_s).first
        if user_id.nil?
          if recording.room.owner_type == 'User'
            user = recording.room.owner
            if user
              recording.metadata.create(:name => BigbluebuttonRails.metadata_user_id.to_s,
                                        :content => user.id)
            end
          else
            space = recording.room.owner
            if space
              recording.metadata.create(:name => BigbluebuttonRails.metadata_user_id.to_s,
                                        :content => space.users.sample)
            end
          end
        end
      end

      # Room metadata
      BigbluebuttonMetadata.populate 2..6 do |meta|
        meta.owner_id = room.id
        meta.owner_type = room.class.to_s
        meta.name = "#{Populator.words(1)}-#{meta.id}"
        meta.content = Populator.words(2..8)
      end
    end

    Post.record_timestamps = false

    puts "* Create posts and last details for spaces (#{Space.count} spaces)"
    Space.all.each do |space|

      total_posts = space.posts.to_a
      # The first Post should not have parent
      final_posts = [] << total_posts.shift

      total_posts.inject final_posts do |posts, post|
        parent = posts.sample
        unless parent.parent_id
          post.update_attribute :parent_id, parent.id
        end
        posts << post
      end

      # Space created recent activity
      if space.admins.length > 0
        space.new_activity :create, space.admins.first
      end

      # Author and recent_activity for posts
      ( space.posts ).each do |item|
        item.author = space.users.sample
        item.save(:validate => false)

        item.new_activity :create, item.author
      end

      # Event participants activity
      if configatron.modules.events.enabled
        space.events.each do |event|
          event.participants.each do |part|
            attend = part.attend? ? :attend : :not_attend
            event.new_activity attend, part.user
          end
        end
      end

      # News activity
      space.news.each do |news|
        author = space.admins.sample
        news.new_activity :create, author
      end

      # Attachment activity
      space.attachments.each do |att|
        author = space.admins.sample
        att.new_activity :create, author
      end

    end

    # Randomize when recent activities were created
    puts "* Randomizing dates for recent activities"
    RecentActivity.all.each do |item|
      item.created_at = rand(@created_at_start_months).months.ago
      item.updated_at = item.created_at
      item.save!
    end

    # done after all the rest to simulate what really happens: users are created enabled
    # and disabled later on
    puts "* Disabling a few users and spaces"
    ids = Space.ids
    ids = ids.sample(Space.count/5) # 1/5th disabled
    Space.where(:id => ids).each do |space|
      space.disable
    end
    users_without_admin = User.where(["(superuser IS NULL OR superuser = ?) AND username NOT IN (?)", false, reserved_usernames])
    ids = users_without_admin.ids
    ids = ids.sample(User.count/5) # 1/5th disabled
    User.where(:id => ids).each do |user|
      user.disable
    end

    puts "* Adding some insecure data to test for script injection"
    add_insecure_data
  end

  private

  def add_insecure_data
    profile_attrs = [:organization, :phone, :mobile, :fax, :address, :city,
                     :zipcode, :province, :country, :prefix_key, :description,
                     :url, :skype, :im, :full_name]

    # Create 2 insecure users
    u = FactoryGirl.create(:user, username: 'insecure1', password: '123456')
    u.profile.update_attributes(attrs_to_hash(Profile, profile_attrs))
    u2 = FactoryGirl.create(:user, username: 'insecure2', password: '123456')
    u2.profile.update_attributes(attrs_to_hash(Profile, profile_attrs))

    space_attrs = [:name, :description]
    s = FactoryGirl.create(:space, attrs_to_hash(Space, space_attrs))
    s.new_activity :create, u
    s.add_member!(u, 'Admin')
    s.add_member!(u2)

    message_attrs = [:title, :body]
    FactoryGirl.create(:private_message, attrs_to_hash(PrivateMessage, message_attrs).merge(receiver: u, sender: u2))

    post_attrs = [:title, :text]
    p = FactoryGirl.create(:post, attrs_to_hash(Post, post_attrs).merge(author: u2, space: s))
    p.new_activity :create, u2

    event_attrs = [:name, :summary, :description, :location, :address]
    e = FactoryGirl.create(:event, attrs_to_hash(MwebEvents::Event, event_attrs).merge(owner_id: s.id, owner_type: 'Space'))
    e.new_activity :create, u

    e2 = FactoryGirl.create(:event, attrs_to_hash(MwebEvents::Event, event_attrs).merge(owner_id: u2.id, owner_type: 'User'))
    e2.new_activity :create, u2

    jr_attrs = [:comment]
    FactoryGirl.create(:join_request, attrs_to_hash(JoinRequest, jr_attrs).merge(introducer: u, candidate: u2, group_id: s.id, group_type: 'Space'))

    invitation_attrs = [:title, :description]
    FactoryGirl.create(:invitation, attrs_to_hash(Invitation, invitation_attrs).merge(type: "WebConferenceInvitation", recipient: u, sender: u2, target: u2.bigbluebutton_room))
  end

  def attrs_to_hash klass, attrs
    arr = attrs.map { |attr| [attr, "<script> alert('#{klass} #{attr} attribute is insecure in this page')</script>"] }
    arr.to_h
  end
end
