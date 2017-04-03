class AddFilenameAndUsernameToAttachmentRecentActivityParameters < ActiveRecord::Migration

  def up
    RecentActivity.where(trackable_type: 'Attachment').find_each do |r|
      if r.trackable.present?
        r.parameters[:filename] = r.trackable.title

        if r.trackable.author.present?
          r.parameters[:username] = r.trackable.author.name if r.parameters[:username].blank?
          r.recipient = r.trackable.author if r.recipient.nil?
        end
      end
      r.save!
    end
  end

  def down
    RecentActivity.where(trackable_type: 'Attachment').find_each do |r|
      r.update_attributes(parameters: {})
    end
  end

end
