namespace :attachment_version do
  desc "Modify attachment folder structure to support versions."
  task :migrate => :environment do
    Dir[File.join(Rails.root.to_s, Attachment.attachment_options[:path_prefix], '*')].each do |parent_dir|
      Dir[File.join(parent_dir, '*')].each do |attachment_id|
        files = Dir[File.join(attachment_id, '*')]
        new_dir = FileUtils.mkdir(File.join(attachment_id, 'v1'))
        FileUtils.mv files, new_dir.to_s
      end
    end
  end
  
  desc "Modify attachment folder structure to change from vestal versions to vcc version system."
  task :rollback => :environment do
    Dir[File.join(Rails.root.to_s, Attachment.attachment_options[:path_prefix], '*')].each do |parent_dir|
      Dir[File.join(parent_dir, '*')].each do |attachment_id|
        v_dir = Dir[File.join(attachment_id, '*')]
        files = Dir[File.join(v_dir.last, '*')]
        FileUtils.mv files, attachment_id.to_s
        v_dir.each do |version_dir|
          FileUtils.remove_dir(version_dir)
        end
      end
    end
  end
end