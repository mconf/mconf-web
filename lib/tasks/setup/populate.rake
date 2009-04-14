namespace :setup do
  desc "Erase and fill database"
  namespace :populate do
    task :default => :populate

    desc "Reload populate data"
    task :reload => [ 'setup:basic_data:reload', :populate ]

    desc "Erase non basic data and fill database"
    task :populate => :environment do
      require 'populator'
      require 'faker'

      # DESTROY #
      [ Space ].each(&:destroy_all)
      # Delete all users except Admin
      users_without_admin = User.all
      users_without_admin.delete(User.find_by_login("vcc"))
      users_without_admin.each(&:destroy)



      User.populate 15 do |user|
        user.login = Faker::Name.name
        user.email = Faker::Internet.email
        user.crypted_password = User.encrypt("test", "")
        user.activated_at = 2.years.ago..Time.now
      end

      Space.populate 20 do |space|
        space.name = Populator.words(1..3).titleize
        space.description = Populator.sentences(1..3)
        space.public = [ true, false ]

        Post.populate 10..100 do |post|
          post.space_id = space.id
          post.title = Populator.words(1..4).titleize
          post.text = Populator.sentences(3..15)
          post.created_at = 2.years.ago..Time.now
          post.updated_at = post.created_at..Time.now
  #        post.tag_with Populator.words(1..4).gsub(" ", ",")
        end

        Event.populate 5..10 do |event|
          event.space_id = space.id
          event.name = Populator.words(1..3).titleize
          event.description = Populator.sentences(0..3)
          event.place = Populator.sentences(0..2)
          event.created_at = 1.years.ago..Time.now
          event.updated_at = event.created_at..Time.now
          event.start_date = event.created_at..1.years.since(Time.now)
          event.end_date = 2.hours.since(event.start_date)..2.days.since(event.start_date)
        end

        Group.populate 2..4 do |group|
          group.space_id = space.id
          group.name = Populator.words(1..3).titleize
        end
      end

      users = User.all
      role_ids = Role.find_all_by_stage_type('Space').map(&:id)

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

        space.groups.each do |group|
          space.users.each do |user|
            next if user.is_a?(SingularAgent)
            group.users << user if rand > 0.7
          end
        end
      end

      Post.record_timestamps = false

      # Posts.parent_id
      Space.all.each do |space|
        total_posts = space.posts
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
          item.author = space.users.rand
          item.save!
        end
      end
    end
  end
end
