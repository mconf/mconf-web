require 'devise/encryptors/station_encryptor'

namespace :db do

  desc "Check the database for inconsistencies and solve them"
  task :become_sane => :environment do
    puts "Checking for moderator_keys that are too long..."
    check_moderator_key_too_long

    puts "Checking for posts with blank text..."
    check_posts_blank_text

    puts "Checking for Spaces with names that are too small..."
    check_spaces_names_too_small

    puts "Check for Spaces with names that are not unique..."
    check_spaces_names_uniqueness
  end

  private

  def check_moderator_key_too_long
    BigbluebuttonRoom.where("length(moderator_key) > 16").each do |r|
      puts "Will truncate the moderator_key of BigbluebuttonRoom with id #{r.id}"
      puts "Old key: #{r.moderator_key}"
      new_key = r.moderator_key[0..15]
      puts "New key: #{new_key}"
      #p "Perform change? (y = yes, n = no, Y = yes to all, N = no to all)"
      puts "Perform change? (Y/n)"
      answer = STDIN.gets.chomp.downcase while answer.nil? || (!answer.blank? && !["y", "n"].include?(answer))
      if answer == "y" || answer.blank?
        r.update_attributes(moderator_key: new_key)
      end
    end
  end

  def check_posts_blank_text
    Post.where("text IS NULL OR length(text) = 0").each do |p|
      puts "Using title as text for Post\##{p.id}"
      p.update_attributes(text: p.title)
    end
  end

  def check_spaces_names_too_small
    # Spaces validate names with minimum length 3.
    Space.where("length(name) < 3").each do |s|
      old_name = s.name
      new_name = old_name + (old_name[old_name.length-1] * (3 - old_name.length))
      puts "Space\##{s.id}'s name is too small. Suggestion: #{new_name}"
      puts "Press ENTER to accept or type the desired name and press ENTER"
      answer = STDIN.gets.chomp
      while !answer.blank? && answer.length < 3
        puts "The desired name is too small. Type another name or press enter to use the suggestion."
        answer = STDIN.gets.chomp
      end
      if answer.blank?
        s.update_attributes(name: new_name)
      else
        s.update_attributes(name: answer)
      end
    end
  end

  def check_spaces_names_uniqueness
    Space.group(:name).having("count(*) > 1").each do |s|
      # Get every space that has the same name as this one.
      base_name = s.name
      all = Space.where(name: s.name).where("id != ?", s.id)
      # all = Space.where(name: s.name) - [s]
      count = 2
      all.each do |space|
        new_name = space.name + count.to_s
        puts "Will update Space\##{space.id}'s name from #{space.name} to #{new_name}"
        puts "Perform change? (Y/n)"
        answer = STDIN.gets.chomp.downcase while answer.nil? || (!answer.blank? && !["y", "n"].include?(answer))
        if answer == "y" || answer.blank?
          space.update_attributes(name: new_name)
        end
        count += 1
      end
    end
  end
end
