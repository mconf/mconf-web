class MoveRecordingsMetadataToDescription < ActiveRecord::Migration
  def up
    # Recordings had metadata to define its title and description, but now they have only a description
    # attribute. So we move the content in the metadata to this new attribute.
    BigbluebuttonRecording.all.each do |rec|
      title = rec.metadata.where(:name => 'mconfweb-title').first
      description = rec.metadata.where(:name => 'mconfweb-description').first
      if rec.description.blank? && !title.nil? && !description.nil?
        rec.update_attribute(:description, "#{title.content}: #{description.content}")
      end
    end
  end

  def down
    # not the exact reverse of up, but better than not being able to rollback
    BigbluebuttonRecording.all.each do |rec|
      title = rec.metadata.where(:name => 'mconfweb-title').first
      title = rec.metadata.create(:name => 'mconfweb-title') if title.nil?
      title.update_attribute(:content, rec.description) if title.content.blank?

      description = rec.metadata.where(:name => 'mconfweb-description').first
      description = rec.metadata.create(:name => 'mconfweb-description') if description.nil?
      description.update_attribute(:content, rec.description) if description.content.blank?
    end
  end
end
