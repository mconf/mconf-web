module PostsHelper

  def time_update(post)
    diff_time = (Time.now - post.updated_at.to_time)/60
    return diff_time/60
  end
end
