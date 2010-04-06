module AgendaEntriesHelper
  
  #Returns the llist of speakers separated by "," and with link to users
  def entry_speakers(entry)
    (entry.actors + [entry.speakers]).compact.map{ |a|
                           a.is_a?(User) ? 
                           link_to(highlight(a.name,@query),user_path(a),:class=>"unified_user") :
                           (a=="" ? nil : a)
                        }.compact.join(",")
  end
end