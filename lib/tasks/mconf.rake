namespace :mconf do

  desc "Generates new dial numbers for all web conference rooms"
  task :generate_dial_numbers => :environment do
    pattern = Site.current.try(:room_dial_number_pattern)

    if pattern.nil?
      puts "Please set a dial number pattern on your site before continuing."
      exit 0
    end

    STDOUT.flush
    puts "This task will override the dial number of ALL your web conference rooms!"
    puts "Are you sure you want to proceed? [y/N]"
    input = STDIN.gets.chomp
    if input.upcase != "Y"
      puts "Aborting."
      exit 0
    end

    BigbluebuttonRoom.find_each do |room|
      number = Mconf::DialNumber.generate(pattern)
      # puts "- Room #{room.name}: #{number}"
      room.update_attributes(dial_number: number)
    end
  end
end
