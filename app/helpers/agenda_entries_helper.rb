module AgendaEntriesHelper
  
  #Returns the llist of speakers separated by "," and with link to users
  def entry_speakers(entry)
    (entry.actors + [entry.speakers]).compact.map{ |a|
                           a.is_a?(User) ? 
                           link_to(highlight(a.name,params[:query]),user_path(a),:class=>"unified_user") :
                           (a=="" ? nil : a)
                        }.compact.join(",")
  end
  
  def duration_options_for_select(total, interval, selected = nil)
    values = (1..total/interval).to_a.map{|x| y = x*interval; ["#{y/60}h #{y%60}m", y]}
    options_for_select(values, selected)
  end
  
  def shared_embed(entry)
    result = '<div id="globalplaza_embed" style="width:481px;"><strong style="display:block;padding:12px 0 4px;">'
    result += link_to(entry.title,space_event_url(entry.space, entry.event, :show_video=> entry.id))   
    result +='</strong><div style="padding:3px 3px 0px 3px;background:#244974">'
    result += entry.video_player
    result += '<div style="padding:0 6px 0px 6px;text-align:right;"><a style="text-decoration:none;outline:none;font-weight:bold;color:#fff" href="http://www.globalplaza.org"><img src="/images/bola_global_peque.png" style="margin-bottom:-3px"/> Global Plaza</a></div>'
    result += '</div></div>'
    
    return result
  end

end