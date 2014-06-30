# This migration will find all the attachments being used by spaces and generate
# new ones using the new libraries we use.

# position of each field in the array of a logo
POS_ID = 0
POS_FILENAME = 4
POS_PARENT_ID = 7
POS_THUMBNAIL = 8
POS_SPACE_ID = 12

class GenerateNewAttachments < ActiveRecord::Migration
  def up
    # select all attachments
    # the Attachment model in the application changed a lot, so we have to do raw sqls
    sql = "SELECT * FROM attachments"
    attachments = ActiveRecord::Base.connection.execute(sql)
    puts "GenerateNewAttachments: found a total of #{attachments.count} attachments"

    thumbnail = 0
    without_target = 0
    with_target = 0
    succeeded = 0
    failed = 0

    attachments.each do |attach|
      remove = false
      puts "  migrating: #{old_path(attach)}"

      if !attach[POS_PARENT_ID].blank? && !attach[POS_THUMBNAIL].blank?
        puts "    had a parent or was a thumbnail"
        thumbnail += 1
        remove = true
        # don't migrate and delete thumbnail attachments
      else
        space = Space.find_by_id(attach[POS_SPACE_ID])
        if space.nil?
          without_target += 1
          puts "    WARN: Migration found an attachment without a proper owner, it will be lost"
          puts "    #{attach.inspect}"
          remove = true
        else
          with_target += 1

          path = old_path(attach)
          puts "    attachment of space #{space.name} is at \"#{path}\", and exists? #{File.file?(path)}"

          if File.file?(path)
            a = Attachment.find_by_id(attach[POS_ID])
            a.attachment = File.open(path)
            # some models might not be with all their data correct so we have to consider that save can fail
            if a.save
              succeeded += 1
              puts "    attachment generated successfully!"
            else
              failed += 1
              puts "    error saving the attachment: #{a.errors.full_messages}"
            end
          else
            failed += 1
            puts "    the file does not exist or is not a file, logo will be lost!"
            remove = true
          end
        end
      end

      if remove
        a = Attachment.find_by_id(attach[POS_ID])
        a.delete
        puts "    attachment being removed from the database (but not from the disk!)"
      end
    end

    puts "----------------------------------------------------------------------------------------"
    puts "GenerateNewAttachments: attachments that had a proper associated space: #{with_target}"
    puts " succeeded: #{succeeded}"
    puts " failed: #{failed}"
    puts "GenerateNewAttachments: attachments that did NOT have a proper associated space: #{without_target}"
    puts "----------------------------------------------------------------------------------------"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

def old_path(att)
  fullid = "%08d" % att[POS_ID]
  "attachments/#{fullid[0..3]}/#{fullid[4..7]}/#{att[POS_FILENAME]}"
end
