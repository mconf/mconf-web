class AddCreationDateToPerformances < ActiveRecord::Migration
  def self.up
    add_column :performances, :created_at, :datetime
    add_column :performances, :updated_at, :datetime

    # For those Performances without created_at or updated_at fields, we estimate the value
    if defined? Performance
      Performance.record_timestamps = false
      Performance.reset_column_information
      Performance.find(:all).each do |p|
        if !(p.created_at.present?)
          adm = Admission.find_by_candidate_id_and_candidate_type_and_group_id_and_group_type_and_accepted(p.agent_id, p.agent_type.to_s, p.stage_id, p.stage_type.to_s, "1")

          if adm.present?
            if adm.processed_at.present?
              p.created_at = adm.processed_at
            elsif adm.updated_at.present?
              p.created_at = adm.updated_at
            else
              p.created_at = p.stage.created_at
            end
          else
            p.created_at = p.stage.created_at
          end

          p.updated_at = p.created_at
          p.save!
        end
      end
    end
  end

  def self.down
    remove_column :performances, :created_at
    remove_column :performances, :updated_at
  end
end
