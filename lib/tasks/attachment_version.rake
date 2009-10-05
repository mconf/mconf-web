namespace :attachment_version do
  desc "Modify attachment folder structure to support versions."
  task :migrate => :environment do
    Dir[File.join(RAILS_ROOT, Attachment.attachment_options[:path_prefix], '*')].each do |parent_dir|
      Dir[File.join(parent_dir, '*')].each do |attachment_id|
        files = Dir[File.join(attachment_id, '*')]
        new_dir = FileUtils.mkdir(File.join(attachment_id, 'v1'))
        FileUtils.mv files, new_dir.to_s
      end
    end
  end
end