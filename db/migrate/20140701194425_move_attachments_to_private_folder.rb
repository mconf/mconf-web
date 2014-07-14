class MoveAttachmentsToPrivateFolder < ActiveRecord::Migration
  def up
    source = "#{Rails.root}/public/uploads"
    destination = "#{Rails.root}/private/uploads"

    Dir.glob(File.join(source, '**/*')).each do |file|
      target = file.gsub(source, "")
      target = File.join(destination, target)
      if File.directory?(file)
        if File.exists?(target)
          puts "file '#{target}' exists"
        else
          puts "mkdir #{target}"
          Dir.mkdir target
        end
      else
        FileUtils.mv file, target, :force => true, :verbose => true
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
