module PostsHelper

  def time_update(post)
    diff_time2 = (Time.now - post.updated_at.to_time)/60
    diff_time = Time.ago(post.updated_at)
    return diff_time/60
  end
end
