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
end