class CleanupEvents < ActiveRecord::Migration
  def up
    remove_column :events, :other_streaming_url
    remove_column :events, :streaming_by_default
    remove_column :events, :recording_bw
    remove_column :events, :web_bw
    remove_column :events, :recording_type
    remove_column :events, :machine_id
    remove_column :events, :colour
    remove_column :events, :repeat
    remove_column :events, :at_job
    remove_column :events, :character
    remove_column :events, :public_read
    remove_column :events, :web_interface
    remove_column :events, :sip_interface
    remove_column :events, :generate_pdf_at
    remove_column :events, :generate_pdf_small_at
    remove_column :events, :manual_configuration
    remove_column :events, :vc_mode
  end

  def down
    add_column :events, :other_streaming_url, :text
    add_column :events, :streaming_by_default, :boolean, :default => true
    add_column :events, :recording_bw, :integer
    add_column :events, :web_bw, :integer
    add_column :events, :recording_type, :integer
    add_column :events, :machine_id, :integer
    add_column :events, :colour, :string, :default => ""
    add_column :events, :repeat, :string
    add_column :events, :at_job, :integer
    add_column :events, :character, :boolean
    add_column :events, :public_read, :boolean
    add_column :events, :web_interface, :boolean, :default => false
    add_column :events, :sip_interface, :boolean, :default => false
    add_column :events, :generate_pdf_at, :datetime
    add_column :events, :generate_pdf_small_at, :datetime
    add_column :events, :manual_configuration, :boolean, :default => false
    add_column :events, :vc_mode, :integer, :default => 0
  end
end
