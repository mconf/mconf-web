class AddCreationDateToPerformances < ActiveRecord::Migration
  def self.up
    add_column :performances, :created_at, :datetime

    # For those Performances without a created_at field, we estimate the value
    minimum_date = DateTime.new(2009,5,6,14,22,0)
    Performance.record_timestamps = false
    Performance.reset_column_information
    Performance.find(:all).each do |p|
      if !(p.created_at.present?)
        adm = Admission.find_by_candidate_id_and_candidate_type_and_group_id_and_group_type_and_accepted(p.agent_id, p.agent_type.to_s, p.stage_id, p.stage_type.to_s, "1")

        if !(adm.nil?)
          if !(adm.processed_at.nil?)
            p.created_at = adm.processed_at
          elsif !(adm.updated_at.nil?)
            p.created_at = adm.updated_at
          elsif !(adm.created_at.nil?)
            p.created_at = adm.created_at
          elsif !(p.stage.nil?)
            if !(p.stage.created_at.nil?)
              p.created_at = p.stage.created_at
            else
              p.created_at = minimum_date
            end
          else
            p.created_at = minimum_date
          end
        elsif !(p.stage.nil?)
          if !(p.stage.created_at.nil?)
            p.created_at = p.stage.created_at
          else
            p.created_at = minimum_date
          end
        else
          p.created_at = minimum_date
        end

        p.save!
      end
    end
  end

  def self.down
    remove_column :performances, :created_at
  end
end
