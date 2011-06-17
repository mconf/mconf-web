namespace :setup do

  desc "Set a new secret_token in initializers/secret_token.rb"
  task :secret => :environment do
    filepath = File.join(Rails.root, "config", "initializers", "secret_token.rb")
    new_filepath = filepath + ".tmp"

    secret = SecureRandom.hex(64)

    File.open(new_filepath, "w") do |new|
      File.open(filepath, "r") do |f|
        f.each_line do |line|
          new_line = "config.secret_token = \"#{secret}\""
          line.gsub!(/config\.secret_token.*=.*/, new_line)
          new.print line
        end
      end
    end
    File.rename(new_filepath, filepath)

    puts "New secret: #{secret}"
  end
end


