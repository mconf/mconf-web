module PrivateMessagesHelper
  def getCospaceUsers ()
    # Fixme, optimize this method
    if @space
      @space.actors - Array(current_user)
    else
      current_user.fellows - Array(current_user)
    end
    
  end
end
