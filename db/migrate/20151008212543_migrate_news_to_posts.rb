NEWS_ID = 0
NEWS_TITLE = 1
NEWS_TEXT = 2
NEWS_SPACE_ID = 3
NEWS_CREATED_AT = 4
NEWS_UPDATED_AT = 5

class MigrateNewsToPosts < ActiveRecord::Migration
  def up
    sql_news = "SELECT news.* FROM news"

    news = ActiveRecord::Base.connection.execute(sql_news)

    Post.record_timestamps = false
    news.each do |n|
      post = Post.create title: n[NEWS_TITLE], text: n[NEWS_TEXT], space_id: n[NEWS_SPACE_ID]

      activities = RecentActivity.where(trackable_type: 'News', trackable_id: n[NEWS_ID])
      activities.each do |act|
        act.update_attributes trackable_type: 'Post', trackable_id: post.id, key: 'post.create'
        # add the creator of the activity as the post author
        post.update_attributes author: act.recipient, created_at: n[NEWS_CREATED_AT], updated_at: n[NEWS_UPDATED_AT]
      end
    end
    Post.record_timestamps = true

    # in case there are still activities for news that were removed, remove them
    RecentActivity.destroy_all(key: 'news.create')
  end

  def down
    # We don't know which posts where news before, can't go back
    raise ActiveRecord::IrreversibleMigration
  end
end
