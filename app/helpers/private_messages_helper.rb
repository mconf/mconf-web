module PrivateMessagesHelper
  def getCospaceUsers ()
    # Fixme, optimize this method
    if @space
      @space.actors
    else
      return Space.find(:all).map{|s| s.actors if s.actors.include?(current_user)}.flatten.uniq.compact  
    end
    
  end
end
