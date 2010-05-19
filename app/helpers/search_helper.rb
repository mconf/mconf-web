module SearchHelper
  def element_partial(element)
    case element
      when Post
        render :partial => 'posts/found_post', :locals => { :post =>  element, :selected_post => false}
      when Space
        render :partial => 'space', :locals => { :space =>  element}
      when Event
        render :partial => element
      when AgendaEntry
        render :partial => 'video', :locals => { :entry =>  element}
    end
  end
end