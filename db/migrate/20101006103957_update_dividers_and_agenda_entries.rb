class UpdateDividersAndAgendaEntries < ActiveRecord::Migration

  # Auxiliary class to avoid validations and callbacks for agenda entries
  class AuxiliaryClass < ActiveRecord::Base
    self.table_name = "agenda_entries"
  end

  def self.up
    AuxiliaryClass.record_timestamps = false
    if defined? Event
      Event.all.each{|e|
        if e.days > 0
          (1..e.days).each do |d|
            day_contents = e.agenda.contents_for_day(d)
            day_contents.each{|c|
              if (c.class == AgendaDivider)
                index_of_content = day_contents.index(c)
                unless index_of_content == (day_contents.length - 1)
                  next_content = day_contents[index_of_content + 1]
                  if (next_content.class == AgendaEntry)
                    next_auxiliary = AuxiliaryClass.find(next_content.id)
                    next_auxiliary.update_attribute(:divider, c.title)
                  end
                end
                c.destroy
              end
            }
          end
        end
      }
    end
  end

  def self.down
    raise "This migration cannot be reverted: UpdateDividersAndAgendaEntries"
  end
end
