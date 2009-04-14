module PrivateMessagesHelper
  def getCospaceUsers ()
    # Fixme, optimize this method
    if @space
      @space.actors.select{|s| s != current_user}
    else
      return Space.find(:all).map{|s| s.actors if s.actors.include?(current_user)}.flatten.uniq.compact.select{|s| s != current_user}  
    end
    
  end
end
