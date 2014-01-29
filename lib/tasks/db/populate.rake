require 'devise/encryptors/station_encryptor'

# TODO: replace Faker by Forgery
namespace :db do

  desc "Populate the DB with random test data. Options: SINCE, CLEAR"
  task :populate => :environment do

    if ENV['SINCE']
      @created_at_start = DateTime.parse(ENV['SINCE']).to_time
    else
      @created_at_start = 6.months.ago
    end
    puts "- Start date set to: #{@created_at_start}"

    require 'populator'
    require 'ffaker'

    username_offset = 0 # to prevent duplicated usernames

    if ENV['CLEAR']
      puts "* Destroying old stuff"
      PrivateMessage.destroy_all
      Statistic.destroy_all
      Permission.destroy_all
      Space.destroy_all
      RecentActivity.destroy_all
      BigbluebuttonRecording.destroy_all
      users_without_admin = User.find_by_id_with_disabled(:all)
      users_without_admin.delete(User.find_by_superuser(true))
      users_without_admin.each(&:destroy)
      rooms_without_admin = BigbluebuttonRoom.all
      rooms_without_admin.delete(User.find_by_superuser(true).bigbluebutton_room)
      rooms_without_admin.each(&:destroy)
    end

    puts "* Create users (15)"
    User.populate 15 do |user|
      user.username = "#{Populator.words(1)}-#{username_offset += 1}"
      user.email = Faker::Internet.email
      user.confirmed_at = @created_at_start..Time.now
      user.disabled = false
      user.notification = User::NOTIFICATION_VIA_EMAIL
      user.encrypted_password = "123"
      user.approved = rand(0) < 0.8 # ~20% marked as not approved

      Profile.populate 1 do |profile|
        profile.user_id = user.id
        profile.full_name = Faker::Name.name
        profile.organization = Populator.words(1..3).titleize
        profile.phone = Faker::PhoneNumber.phone_number
        profile.mobile = Faker::PhoneNumber.phone_number
        profile.fax = Faker::PhoneNumber.phone_number
        profile.address = Faker::Address.street_address
        profile.city = Faker::Address.city
        profile.zipcode = Faker::Address.zip_code
        profile.province = Faker::Address.uk_county
        profile.country = Faker::Address.uk_country
        profile.prefix_key = Faker::Name.prefix
        profile.description = Populator.sentences(1..3)
        profile.url = "http://" + Faker::Internet.domain_name + "/" + Populator.words(1)
        profile.skype = Populator.words(1)
        profile.im = Faker::Internet.email
        profile.visibility = Populator.value_in_range((Profile::VISIBILITY.index(:everybody))..(Profile::VISIBILITY.index(:nobody)))
      end
    end
    User.all.each do |user|
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
      senders = User.all.reject!{ |u| u == user }.map(&:id)
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
      end until Space.find_by_name(name).nil? and name.length >= 3
      space.name = name
      space.description = Populator.sentences(1..3)
      space.public = [ true, false ]
      space.disabled = false
      space.permalink = name.parameterize

      Post.populate 10..50 do |post|
        post.space_id = space.id
        post.title = Populator.words(1..4).titleize
        post.text = Populator.sentences(3..15)
        post.spam = false
        post.created_at = @created_at_start..Time.now
        post.updated_at = post.created_at..Time.now
        post.spam = rand(0) > 0.9 # ~10% marked as spam
      end

      puts "* Create spaces: events for \"#{space.name}\" (5..10)"
      available_users = User.all.dup
      Event.populate 5..10 do |event|
        event.space_id = space.id
        event.name = Populator.words(1..3).titleize
        event.description = Populator.sentences(0..3)
        event.place = Populator.sentences(0..2)
        event.spam = false
        event.created_at = @created_at_start..Time.now
        event.updated_at = event.created_at..Time.now
        event.start_date = event.created_at..1.years.since(Time.now)
        event.end_date = 2.hours.since(event.start_date)..2.days.since(event.start_date)
        event.author_id = available_users.delete_at((rand * available_users.size).to_i)
        event.spam = rand(0) > 0.9 # ~10% marked as spam
      end

      News.populate 2..10 do |news|
        news.space_id = space.id
        news.title = Populator.words(3..8).titleize
        news.text = Populator.sentences(2..10)
        news.created_at = @created_at_start..Time.now
        news.updated_at = news.created_at..Time.now
      end
    end

    puts "* Create spaces: saving events to generate permalinks"
    Event.find_each(&:save!) # to generate the permalink

    puts "* Create spaces: webconference rooms"
    Space.all.each do |space|
      if space.bigbluebutton_room.nil?
        BigbluebuttonRoom.populate 1 do |room|
          room.server_id = BigbluebuttonServer.default.id
          room.owner_id = space.id
          room.owner_type = 'Space'
          room.name = space.name
          room.meetingid = "#{SecureRandom.hex(16)}-#{Time.now.to_i}"
          room.attendee_password = "ap"
          room.moderator_password = "mp"
          room.private = !space.public
          room.logout_url = "/feedback/webconf"
          room.external = false
          room.param = space.name.parameterize.downcase
          room.duration = 0
          room.record = false
        end
      end
    end

    puts "* Create spaces: adding users"
    Space.all.each do |space|
      role_ids = Role.find_all_by_stage_type('Space').map(&:id)
      available_users = User.all.dup

      puts "* Create spaces: \"#{space.name}\" - add first admin"
      Permission.populate 1 do |permission|
        user = available_users.delete_at((rand * available_users.size).to_i)
        permission.user_id = user.id
        permission.subject_id = space.id
        permission.subject_type = 'Space'
        permission.role_id = Role.find_all_by_stage_type_and_name('Space', 'Admin')
        permission.created_at = user.created_at
        permission.updated_at = permission.created_at
      end

      puts "* Create spaces: \"#{space.name}\" - add more users (3..10)"
      Permission.populate 3..10 do |permission|
        user = available_users.delete_at((rand * available_users.size).to_i)
        permission.user_id = user.id
        permission.subject_id = space.id
        permission.subject_type = 'Space'
        permission.role_id = role_ids
        permission.created_at = user.created_at
        permission.updated_at = permission.created_at
      end

      puts "* Create spaces: \"#{space.name}\" - add users for events"
      event_role_ids = Role.find_all_by_stage_type('Event').map(&:id)
      space.events.each do |event|
        available_event_participants = space.users.dup
        Participant.populate 0..space.users.count do |participant|
          participant_aux = available_event_participants.delete_at((rand * available_event_participants.size).to_i)
          participant.user_id = participant_aux.id
          participant.email = participant_aux.email
          participant.event_id = event.id
          participant.created_at = event.created_at..Time.now
          participant.updated_at = participant.created_at..Time.now
          participant.attend = (rand(0) > 0.5)

          Permission.populate 1 do |permission|
            permission.user_id = participant.user_id
            permission.subject_id = event.id
            permission.subject_type = 'Event'
            permission.role_id = event_role_ids
            permission.created_at = participant.created_at
            permission.updated_at = permission.created_at
          end
        end
      end

    end

    puts "* Create recordings and metadata for all webconference rooms (#{BigbluebuttonRoom.count} rooms)"
    BigbluebuttonRoom.all.each do |room|

      BigbluebuttonRecording.populate 2..10 do |recording|
        recording.room_id = room.id
        recording.server_id = room.server.id
        recording.recordid = "rec-#{SecureRandom.hex(16)}-#{Time.now.to_i}"
        recording.meetingid = room.meetingid
        recording.name = Populator.words(3..5).titleize
        recording.published = true
        recording.available = true
        recording.start_time = 5.months.ago..Time.now
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
        # Note: make a few without playback formats, meaning that the recording is still being processed
        BigbluebuttonPlaybackFormat.populate 0..3 do |format|
          format.recording_id = recording.id
          format.format_type = "#{Populator.words(1)}-#{format.id}"
          format.url = "http://" + Faker::Internet.domain_name + "/playback/" + format.format_type
          format.length = Populator.value_in_range(32..128)
        end
      end

      # Basic metadata needed in all recordings
      room.recordings.each do |recording|
        # this is created by BigbluebuttonRails normally
        user_id = recording.metadata.where(:name => BigbluebuttonRails.metadata_user_id.to_s).first
        if user_id.nil?
          if recording.room.owner_type == 'User'
            user = recording.room.owner
            recording.metadata.create(:name => BigbluebuttonRails.metadata_user_id.to_s,
                                      :content => user.id)
          else
            space = recording.room.owner
            recording.metadata.create(:name => BigbluebuttonRails.metadata_user_id.to_s,
                                      :content => space.users[rand(space.users.length)])
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

    puts "* Create statistics and last details for spaces"
    Space.all.each do |space|
      Statistic.populate 1 do |statistic|
        statistic.url = "/spaces/" + space.permalink
        statistic.unique_pageviews = 0..300
      end

      total_posts = space.posts.dup
      # The first Post should not have parent
      final_posts = Array.new << total_posts.shift

      total_posts.inject final_posts do |posts, post|
        parent = posts[(rand * posts.size).to_i]
        unless parent.parent_id
          post.update_attribute :parent_id, parent.id
        end
        posts << post
      end

      # Space created recent activity
      space.new_activity :create, space.admins.first

      # Author and recent_activity for posts/events
      ( space.posts + space.events ).each do |item|
        item.author = space.users[rand(space.users.length)]
        item.save(:validate => false)

        item.new_activity :create, item.author
      end

      # Event participants activity
      space.events.each do |event|
        event.participants.each do |part|
          attend = part.attend? ? :attend : :not_attend
          event.new_activity attend, part.user
        end
      end

      # News activity
      space.news.each do |news|
        news.new_activity :create, space.admins[rand(space.admins.length)]
      end

      # Attachment activity
      space.attachments.each do |att|
        att.new_activity :create, space.users[rand(space.users.length)]
      end

    end

  end
end
