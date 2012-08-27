module AgendaEntriesHelper

  #Returns the llist of speakers separated by "," and with link to users
  def entry_speakers(entry)
    (entry.actors + [entry.speakers]).compact.map{ |a|
                           a.is_a?(User) ?
                           link_to(highlight(a.name,params[:query]),user_url(a),:class=>"unified_user") :
                           (a=="" ? nil : a)
                        }.compact.join(", ")
  end

  #Returns the llist of speakers separated by "," and with link to users opened in new window
  def entry_speakers_for_scorm(entry)
    (entry.actors + [entry.speakers]).compact.map{ |a|
                           a.is_a?(User) ?
                           link_to(highlight(a.name,params[:query]),user_url(a),:class=>"unified_user", :target=>"_blank") :
                           (a=="" ? nil : a)
                        }.compact.join(", ")
  end

  def duration_options_for_select(total, interval, selected = nil)
    values = (1..total/interval).to_a.map{|x| y = x*interval; ["#{y/60}h #{y%60}m", y]}
    options_for_select(values, selected)
  end

  def shared_embed(entry)
    result = '<div id="mconf_embed" style="width:645px;"><strong style="display:block;padding:12px 0 4px;">'
    result += link_to(entry.title,space_event_url(entry.space, entry.event, :show_video=> entry.id))
    result +='</strong><div style="padding:3px 3px 0px 3px;background:#244974">'
    result += '<div style="padding:0 6px 0px 6px;text-align:right;"><a style="text-decoration:none;outline:none;font-weight:bold;color:#fff" href="http://mconf.inf.ufrgs.br">Mconf</a></div>'
    result += '</div></div>'

    return result
  end

end
