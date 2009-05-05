class UpdateAdmissions < ActiveRecord::Migration
  def self.up
    add_column :admissions, :introducer_id, :integer
    add_column :admissions, :introducer_type, :string
    add_column :admissions, :comment, :text
  end

  def self.down
    remove_column :admissions, :introducer_id
    remove_column :admissions, :introducer_type
    remove_column :admissions, :comment
  end
end
