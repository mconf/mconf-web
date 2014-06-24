# Will create recent activity (public activity) entries for objects that were
# created. When Mconf-Web switched the way activities are created, all activities
# were lost, so here some are created so the lists won't be totally empty.
# Will only create activities that do not exist yet, just in case we're updating
# a database that already has activities created.

class CreateRecentActivities < ActiveRecord::Migration
  def up

    puts "CreateRecentActivities: creating activities for Spaces"
    Space.all.each do |space|
      unless PublicActivity::Activity.where(:key => 'space.create', :trackable_id => space.id).length > 0
        activity = space.create_activity "create", :owner => space
        activity.created_at = space.created_at
        activity.updated_at = space.created_at
        activity.save
      end
    end

    puts "CreateRecentActivities: creating activities for Posts"
    Post.all.each do |post|
      unless PublicActivity::Activity.where(:key => 'post.create', :trackable_id => post.id).length > 0
        owner = post.author
        if owner
          activity = post.create_activity "create", :owner => post.space, :parameters => { :user_id => owner.id, :username => owner.name }
          activity.created_at = post.created_at
          activity.updated_at = post.created_at
          activity.save
        end
      end
    end

    puts "CreateRecentActivities: creating activities for Events"
    MwebEvents::Event.all.each do |event|
      unless PublicActivity::Activity.where(:key => 'event.create', :trackable_id => event.id).length > 0
        owner = event.owner
        if owner
          activity = event.create_activity "create", :owner => owner, :parameters => { :user_id => owner.id, :username => owner.name }
          activity.created_at = event.created_at
          activity.updated_at = event.created_at
          activity.save
        end
      end
    end

    puts "CreateRecentActivities: creating activities for News"
    News.all.each do |news|
      unless PublicActivity::Activity.where(:key => 'news.create', :trackable_id => news.id).length > 0
        activity = news.create_activity "create", :owner => news.space
        activity.created_at = news.created_at
        activity.updated_at = news.created_at
        activity.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
