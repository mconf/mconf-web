namespace :setup do

  desc "Populate the DB with random test data"
  task :populate => :environment do

    require 'populator'
    require 'ffaker'

    # DESTROY #
    spaces = Space.all
    spaces.delete(Space.find(1))
    spaces.each(&:destroy)
    # Delete all users except Admin
    users_without_admin = User.find_with_disabled(:all)
    users_without_admin.delete(User.find_by_login("mconf"))
    users_without_admin.each(&:destroy)

    puts "* Create Users"
    User.populate 15 do |user|
      user.login = Populator.words(1)
      user.email = Faker::Internet.email
      user.crypted_password = User.encrypt("test", "")
      user.activated_at = 2.years.ago..Time.now
      user.disabled = false
      user.notification = User::NOTIFICATION_VIA_EMAIL

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

    puts "* Create Users: webconference rooms"
    User.all.each do |user|
      if user.bigbluebutton_room.nil?
        user.create_bigbluebutton_room :owner => user,
                                       :server => BigbluebuttonServer.first,
                                       :param => user.login,
                                       :name => user.profile.full_name
      end
    end

    puts "* Create spaces"
    Space.populate 10 do |space|
      space.name = Populator.words(1..3).capitalize
      space.permalink = PermalinkFu.escape(space.name.titleize)
      space.description = Populator.sentences(1..3)
      space.public = [ true, false ]
      space.disabled = false

      Post.populate 10..50 do |post|
        post.space_id = space.id
        post.title = Populator.words(1..4).titleize
        post.text = Populator.sentences(3..15)
        post.spam = false
        post.created_at = 2.years.ago..Time.now
        post.updated_at = post.created_at..Time.now
      end

      puts "* Create spaces: events for \"#{space.name}\""
      Event.populate 5..10 do |event|
        event.space_id = space.id
        event.name = Populator.words(1..3).titleize
        event.description = Populator.sentences(0..3)
        event.place = Populator.sentences(0..2)
        event.spam = false
        event.created_at = 1.years.ago..Time.now
        event.updated_at = event.created_at..Time.now
        event.start_date = event.created_at..1.years.since(Time.now)
        event.end_date = 2.hours.since(event.start_date)..2.days.since(event.start_date)
        event.vc_mode = Event::VC_MODE.index(:in_person)
        event.permalink = PermalinkFu.escape(event.name)

        Agenda.populate 1 do |agenda|
          agenda.event_id = event.id
          agenda.created_at = event.created_at..Time.now
          agenda.updated_at = agenda.created_at..Time.now

          # inferior limit for the start time of the first agenda entry
          last_agenda_entry_end_time = event.start_date
          first_agenda_entry = true

          AgendaEntry.populate 2..10 do |agenda_entry|
            agenda_entry.agenda_id = agenda.id
            agenda_entry.title = Populator.words(1..3).titleize
            agenda_entry.description = Populator.sentences(0..2)
            agenda_entry.speakers = Populator.words(2..6).titleize
            if first_agenda_entry
              # fixing the start_time of the first agenda entry to the start_date of the event
              agenda_entry.start_time = event.start_date
              first_agenda_entry = false
            else
              agenda_entry.start_time = last_agenda_entry_end_time..event.end_date
            end
            agenda_entry.end_time = agenda_entry.start_time..event.end_date

            # updating the inferior limit for the next agenda entry
            last_agenda_entry_end_time = agenda_entry.end_time

            agenda_entry.created_at = agenda.created_at..Time.now
            agenda_entry.updated_at = agenda_entry.created_at..Time.now
            agenda_entry.embedded_video = "<object width='425' height='344'><param name='movie' " +
              "value='http://www.youtube.com/v/9ri3y2RDzUM&hl=es_ES&fs=1&'></param><param name='allowFullScreen'" +
              " value='true'></param><param name='allowscriptaccess' value='always'></param><embed" +
              " src='http://www.youtube.com/v/9ri3y2RDzUM&hl=es_ES&fs=1&' type='application/x-shockwave-flash'" +
              " allowscriptaccess='always' allowfullscreen='true' width='425' height='344'></embed></object>"
            agenda_entry.video_thumbnail = "http://i2.ytimg.com/vi/9ri3y2RDzUM/default.jpg"
          end

          # fixing the end_date of the event to the end_time of the last_agenda_entry
          event.end_date = last_agenda_entry_end_time

        end

        Statistic.populate 1 do |statistic|
          statistic.url = "/spaces/" + space.permalink + "/events/" + event.permalink
          statistic.unique_pageviews = 0..100
        end
      end

      News.populate 2..10 do |news|
        news.space_id = space.id
        news.title = Populator.words(3..8).titleize
        news.text = Populator.sentences(2..10)
        news.created_at = 2.years.ago..Time.now
        news.updated_at = news.created_at..Time.now
      end

      Statistic.populate 1 do |statistic|
        statistic.url = "/spaces/" + space.permalink
        statistic.unique_pageviews = 0..100
      end
    end

    users = User.all
    role_ids = Role.find_all_by_stage_type('Space').map(&:id)

    puts "* Create spaces: webconference rooms"
    Space.all.each do |space|
      if space.bigbluebutton_room.nil?
        BigbluebuttonRoom.populate 1 do |room|
          room.server_id = BigbluebuttonServer.first
          room.owner_id = space.id
          room.owner_type = 'Space'
          room.name = space.name
          room.meetingid = space.permalink
          room.randomize_meetingid = false
          room.attendee_password = "ap"
          room.moderator_password = "mp"
          room.private = !space.public
          room.logout_url = "/spaces/#{space.permalink}"
          room.external = false
          room.param = space.name.parameterize.downcase
        end
      end
    end

    puts "* Create spaces: logos"
    logos = Dir.entries("public/images/default_space_logos/")
    logos.delete(".")
    logos.delete("..")
    Space.all.each do |space|
      space.default_logo = "default_space_logos/" + logos[rand(logos.length)].to_s
      space.save
    end

    puts "* Create spaces: more data..."
    Space.all.each do |space|
      available_users = users.dup

      Performance.populate 5..7 do |performance|
        user = available_users.delete_at((rand * available_users.size).to_i)
        performance.stage_id = space.id
        performance.stage_type = 'Space'
        performance.role_id = role_ids
        performance.agent_id = user.id
        performance.agent_type = 'User'
      end

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

          Performance.populate 1 do |performance|
            performance.stage_id = event.id
            performance.stage_type = 'Event'
            performance.role_id = event_role_ids
            performance.agent_id = participant.user_id
            performance.agent_type = 'User'
            performance.created_at = participant.created_at
            performance.updated_at = performance.created_at
          end
        end
      end

    end

    Post.record_timestamps = false

    # Posts.parent_id
    Space.all.each do |space|
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

      # Author
      ( space.posts + space.events ).each do |item|
        item.author = space.users[rand(space.users.length)]
        # Save the items without performing validations, to allow further testing
        item.save(false)
      end

    end

    Site.find(1).update_attribute(:signature, "Mconf")

  end
end
