namespace :secret do

  desc "Set a new secret_token and secret_key_base in initializers/secret_token.rb, also set a new pepper and secret key in initializers/devise.rb"
  task reset: :environment do
    filepath = File.join(Rails.root, "config", "initializers", "secret_token.rb")
    new_filepath = filepath + ".tmp"

    secret_token = SecureRandom.hex(64)
    secret_key_base = SecureRandom.hex(64)

    File.open(new_filepath, "w") do |new|
      File.open(filepath, "r") do |f|
        f.each_line do |line|
          if line.match(/config\.secret_token.*=.*/)
            new_line = "config.secret_token = \"#{secret_token}\""
            line.gsub!(/config\.secret_token.*=.*/, new_line)
          elsif line.match(/config\.secret_key_base.*=.*/)
            new_line = "config.secret_key_base = \"#{secret_key_base}\""
            line.gsub!(/config\.secret_key_base.*=.*/, new_line)
          end
          new.print line
        end
      end
    end
    File.rename(new_filepath, filepath)

    puts "New secret_token: #{secret_token}"
    puts "New secret_key_base: #{secret_key_base} \n\n"

    filepath = File.join(Rails.root, "config", "initializers", "devise.rb")
    new_filepath = filepath + ".tmp"

    pepper = SecureRandom.hex(64)
    secret_key = SecureRandom.hex(64)

    File.open(new_filepath, "w") do |new|
      File.open(filepath, "r") do |f|
        f.each_line do |line|
          if line.match(/config\.pepper.*=.*/)
            new_line = "config.pepper = \"#{pepper}\""
            line.gsub!(/config\.pepper.*=.*/, new_line)
          elsif line.match(/config\.secret_key.*=.*/)
            new_line = "config.secret_key = \"#{secret_key}\""
            line.gsub!(/config\.secret_key.*=.*/, new_line)
          end
          new.print line
        end
      end
    end
    File.rename(new_filepath, filepath)

    puts "New pepper: #{pepper}"
    puts "New secret_key: #{secret_key} \n\n"

  end
end
