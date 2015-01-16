# position of each field in the array of a logo
POS_ID = 0
POS_FILENAME = 4
POS_TARGET_TYPE = 10
POS_TARGET_ID = 11

# This migration will find all the old logos being used by spaces and profiles and generate
# new logos using the new libraries we use.
class GenerateNewLogos < ActiveRecord::Migration

  # Fake models we need to save the new logo and create its versions
  class Space < ActiveRecord::Base
    mount_uploader :logo_image, LogoImageUploader
    attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  end
  class Profile < ActiveRecord::Base
    attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
    mount_uploader :logo_image, LogoImageUploader
  end
  LogoImageUploader.class_eval do
    # Since our models are defined here, inside the migration, the uploader ends up saving
    # the files in the wrong folder. So we have to adjust the path a bit.
    def store_dir
      model_name = model.class.to_s.gsub(/.*::/, "").underscore
      "uploads/#{model_name}/#{mounted_as}/#{model.id}"
    end
  end

  def up
    # select all logos
    # there's no Logo model anymore, so we have to do a raw sql
    sql = "SELECT * FROM logos"
    logos = ActiveRecord::Base.connection.execute(sql)
    puts "MoveOldLogos: found a total of #{logos.count} logos"

    without_target = 0
    with_target = 0
    succeeded = 0
    failed = 0

    logos.each do |logo|

      # find the space or user associated with the logo
      target = find_target(logo)
      if target.nil?
        without_target += 1
        puts "MoveOldLogos: WARN: Migration found a logo without a proper owner, logo will be lost"
        puts "    #{logo.inspect}"
      else
        with_target += 1

        fullpath = File.join(Rails::root, old_path(logo))

        if target.is_a?(Profile)
          puts "MoveOldLogos: logo for user #{target.full_name} is at #{fullpath}, and exists? #{File.exists?(fullpath)}"
        else
          puts "MoveOldLogos: logo for space #{target.name} is at #{fullpath}, and exists? #{File.exists?(fullpath)}"
        end

        if File.exists?(fullpath)
          target.logo_image = File.open(fullpath)
          target.logo_image.recreate_versions!

          # some models might not be with all their data correct (e.g. some have names with 2 chars
          # that results in errors generating the permalink), so we have to consider that save can fail
          if target.save
            puts "    logo updated in the model, moving the file to the new folder"
            succeeded += 1
            puts "    logo generated succesfully!"
          else
            failed += 1
            puts "    error saving the target: #{target.errors.full_messages}"
          end
        else
          failed += 1
          puts "    the file does not exist! logo will be lost"
        end
      end
    end

    puts "----------------------------------------------------------------------------------------"
    puts "MoveOldLogos: logos that had a proper associated space/user: #{with_target}"
    puts "    succeeded: #{succeeded}"
    puts "    failed: #{failed}"
    puts "MoveOldLogos: logos that did NOT have a proper associated space/user: #{without_target}"
    puts "----------------------------------------------------------------------------------------"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def find_target(logo)
    if logo[POS_TARGET_TYPE] == "Space"
      Space.find_by_id(logo[POS_TARGET_ID])
    elsif logo[POS_TARGET_TYPE] == "Profile"
      Profile.find_by_id(logo[POS_TARGET_ID])
    else
      nil
    end
  end

  def old_path(logo)
    fullid = "%08d" % logo[POS_ID]
    "public/logos/#{fullid[0..3]}/#{fullid[4..7]}/#{logo[POS_FILENAME]}"
  end

end
