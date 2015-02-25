require 'devise/encryptors/station_encryptor'

namespace :db do
  BBBROOM_MOD_KEY_MAX_LENGTH = 16
  BBBROOM_ATT_KEY_MAX_LENGTH = 16
  BBBROOM_NAME_MAX_LENGTH = 150
  SPACE_NAME_MIN_LENGTH = 3

  desc "Check the database for inconsistencies and solve them"
  task :sanify => :environment do
    puts "Checking for moderator_keys that are too long..."
    check_moderator_key_too_long

    puts "Checking for attendee_keys that are too long..."
    check_attendee_key_too_long

    puts "Checking for bbbroom names that are too long..."
    check_bbbroom_name_too_long

    puts "Checking for posts with blank text..."
    check_posts_blank_text

    puts "Checking for Spaces with names that are too small..."
    check_spaces_names_too_small

    puts "Check for Spaces with names that are not unique..."
    check_spaces_names_uniqueness
  end

  private

  def check_moderator_key_too_long
    BigbluebuttonRoom.where("length(moderator_key) > #{BBBROOM_MOD_KEY_MAX_LENGTH}").each do |r|

      puts "Will truncate the moderator_key of BigbluebuttonRoom with id #{r.id}"
      puts "Old key: #{r.moderator_key}"

      new_key = r.moderator_key.slice(0, BBBROOM_MOD_KEY_MAX_LENGTH)

      puts "New key: #{new_key}"
      puts "Perform change? (Y/n)"

      answer = STDIN.gets.chomp.downcase while answer.nil? || (!answer.blank? && !["y", "n"].include?(answer))

      if answer == "y" || answer.blank?
        r.update_attribute(:moderator_key, new_key)
      end
    end
  end

  def check_attendee_key_too_long
    BigbluebuttonRoom.where("length(attendee_key) > #{BBBROOM_ATT_KEY_MAX_LENGTH}").each do |r|

      new_key = r.attendee_key.slice(0, BBBROOM_ATT_KEY_MAX_LENGTH)

      puts "Will truncate the attendee key of Bigbluebutton Room with id #{r.id}"
      puts "Old key: #{r.attendee_key} . New key: #{new_key}"

      answer = STDIN.gets.chomp.downcase while answer.nil? || !(answer.blank? || ["y", "n"].include(answer))

      if answer == "y" || answer.blank?
        r.update_attribute(:attendee_key, new_key)
      end
    end
  end

  def check_bbbroom_name_too_long
    BigbluebuttonRoom.where("length(name) > #{BBBROOM_NAME_MAX_LENGTH}").each do |r|
      new_name = r.name.slice(0, BBBROOM_NAME_MAX_LENGTH)

      puts "Truncating name of BigbluebuttonRoom\##{r.id} to #{new_name}"

      r.update_attribute(:name, new_name)
    end
  end

  def check_posts_blank_text
    Post.where("text IS NULL OR length(text) = 0").each do |p|
      # Posts without either text or title are destroyed.
      if p.title.nil?
        puts "Destroying post #{p.id}, since it has no title"
        p.destroy
      else
        puts "Using title as text for Post\##{p.id}"
        p.update_attribute(:text, p.title)
      end
    end
  end

  def check_spaces_names_too_small
    # Spaces validate names with minimum length 3.
    Space.where("length(name) < #{SPACE_NAME_MIN_LENGTH}").each do |s|

      old_name = s.name
      l = old_name.length

      # Fill the string with the last character, to make it 3 chars long.
      base_name = old_name + (old_name.last * (SPACE_NAME_MIN_LENGTH - l))
      new_name = base_name
      # If the generated name already exists?
      count = 2
      until Space.where(name: new_name).empty?
        new_name = base_name + count.to_s
        count += 1
      end

      puts "Space\##{s.id}'s name is too small (\"#{old_name}\"). Suggestion: #{new_name}"
      puts "Press ENTER to accept or type the desired name and press ENTER"

      answer = STDIN.gets.chomp
      while !answer.blank? && answer.length < 3
        puts "The desired name is too small. Type another name or press enter to use the suggestion."
        answer = STDIN.gets.chomp
      end

      if answer.blank?
        s.update_attribute(:name, new_name)
      else
        s.update_attribute(:name, answer)
      end
    end
  end

  def check_spaces_names_uniqueness
    # For every space that has a name that is not unique
    Space.group(:name).having("count(*) > 1").each do |s|
      puts "Some spaces have the same name as Space\##{s.id} (#{s.name})"

      # Get every space that has the same name as this one.
      all = Space.where(name: s.name).where("id != ?", s.id)
      # all = Space.where(name: s.name) - [s]

      count = 2
      all.each do |space|
        new_name = space.name + count.to_s
        until Space.where(name: new_name).empty?
          count += 1
          new_name = space.name + count.to_s
        end
        puts "Will update Space\##{space.id}'s name from #{space.name} to #{new_name}"
        puts "Perform change? (Y/n)"
        answer = STDIN.gets.chomp.downcase while answer.nil? || (!answer.blank? && !["y", "n"].include?(answer))
        if answer == "y" || answer.blank?
          space.update_attribute(:name, new_name)
        end
        count += 1
      end
    end
  end
end
