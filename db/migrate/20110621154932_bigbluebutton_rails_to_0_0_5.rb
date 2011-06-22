class BigbluebuttonRailsTo005 < ActiveRecord::Migration

  def self.up
    add_column :bigbluebutton_rooms, :external, :boolean, :default => false
    add_column :bigbluebutton_rooms, :param, :string
    add_column :bigbluebutton_servers, :param, :string

    puts "===== Creating values for :param"
    BigbluebuttonRoom.all.each do |r|
      r.update_attributes(:param => r.name.parameterize.downcase)
      self.update_param(r)
    end
    BigbluebuttonServer.all.each do |s|
      s.update_attributes(:param => s.name.parameterize.downcase)
      self.update_param(s)
    end

  end

  def self.down
    remove_column :bigbluebutton_rooms, :external
    remove_column :bigbluebutton_rooms, :param
    remove_column :bigbluebutton_servers, :param
  end

  # Method to automatically create the :param attribute for rooms and servers
  def self.update_param(r)
    success = true

    unless r.errors.empty?
      puts "* Errors trying to save:"
      r.errors.each { |p| puts "  param: #{p}, value: #{r.send(p)}, error: #{r.errors[p]}" }
      success = false
    end

    if r.errors.has_key?(:param)
      success = false
      5.times do
        param = r.name.parameterize.downcase + "-" + ActiveSupport::SecureRandom.random_number(9999).to_s
        puts "* Trying #{param}"
        success = r.update_attributes(:param => param)
        if success
          puts "* OK!"
          break
        end
      end
    end

    if success
      puts "Using #{r.class.name}.param = \"#{r.param}\" (#{r.class.name}.name = \"#{r.name}\")"
    else
      puts "***** FAILED saving #{r.class.name}.name = \"#{r.name}\". You will have to do it manually."
    end
  end

end
