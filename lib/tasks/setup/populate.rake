namespace :setup do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'

    [ Space ].each(&:delete_all)

    Space.populate 20 do |space|
      space.name = Populator.words(1..3).titleize
      space.public = [ true, false ]

      Post.populate 10..100 do |post|
        post.space_id = space.id
        post.title = Populator.words(1..4).titleize
        post.text = Populator.sentences(3..15)
        post.created_at = 2.years.ago..Time.now
#        post.tag_with Populator.words(1..4).gsub(" ", ",")
      end
    end

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
    end

    User.populate 15 do |user|
      user.login = Faker::Name.name
      user.email = Faker::Internet.email
      user.activated_at = 2.years.ago..Time.now
    end
  end
end
