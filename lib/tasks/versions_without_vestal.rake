namespace :versions_without_vestal do
  desc "Modify attachment folder structure to change from vestal versions to vcc version system."
  task :migrate => :environment do
    Dir[File.join(RAILS_ROOT, Attachment.attachment_options[:path_prefix], '*')].each do |parent_dir|
      Dir[File.join(parent_dir, '*')].each do |attachment_id|
        v_dir = Dir[File.join(attachment_id, '*')].last
        files = Dir[File.join(v_dir, '*')]
        FileUtils.mv files, parent_dir.to_s
        FileUtils.rmdir_r(File.join(attachment_id, 'v*'))
      end
    end
  end
end