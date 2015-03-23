class AddFilenameAndUsernameToAttachmentRecentActivityParameters < ActiveRecord::Migration

  def up
    RecentActivity.where(trackable_type: 'Attachment').each do |r|
      if r.trackable.present?
        r.parameters[:filename] = r.trackable.title
      end
      if r.recipient.present? && r.parameters[:username].blank?
        r.parameters[:username] = r.recipient.name
      end
      r.save!
    end
  end

  def down
    RecentActivity.where(trackable_type: 'Attachment').each do |r|
      r.update_attributes(parameters: {})
    end
  end

end
