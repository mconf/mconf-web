namespace :station do
  namespace :attachment_fu do
    desc "Copy database files to filesystem"
    task :db2file => :environment do
      raise Exception.new("Error: You must provide a MODEL") unless ENV["MODEL"]

      klass = ENV["MODEL"].constantize

      klass.record_timestamps = false

      klass.class_eval do
        belongs_to :db_file

        def db2file
          return if db_file.blank?

          set_temp_data db_file.data
          save_to_storage
        end
      end

      klass.all.map(&:db2file)
    end

    desc "Regenerate thumbnails"
    task :regenerate_thumbs => :environment do
      raise Exception.new("Error: You must provide a MODEL") unless ENV["MODEL"]

      klass = ENV["MODEL"].constantize

      klass.record_timestamps = false

      klass.all(:conditions => { :parent_id => nil }).each do |p|
        puts "Regenerating thumbnails for #{ p.filename }"

        begin
          temp_file = p.create_temp_file
        rescue
          puts "Failed to create temp file for #{p.id}"
          next
        end

        p.attachment_options[:thumbnails].each { |suffix, size|
          begin
            p.create_or_update_thumbnail(temp_file, suffix, *size)
          rescue
            puts "Failed to process #{p.id}"
            next
          end
        }

        # Delete obsolete thumbnails
        p.thumbnails.select{ |t| 
          ! p.attachment_options[:thumbnails].keys.include?(t.thumbnail)
        }.each(&:destroy)
      end
    end
  end
end

