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

    User.populate 15 do |user|
      user.login = Faker::Name.name
      user.email = Faker::Internet.email
      user.activated_at = 2.years.ago..Time.now
    end
  end
end
