class AssureUniquenessInUserLoginAndSpacePermalink < ActiveRecord::Migration

  def self.up

    # Checks for conflicts in Spaces' permalinks and Users' logins.
    # In any conflict, changes the space's permalink to a new unique value
    Space.all.each do |space|

      # code adapted from permalink_fu
      limit = space.class.columns_hash[space.class.permalink_field].limit
      base = space.name[0..limit - 1].parameterize.downcase
      counter = 1

      while Space.where(:permalink => space.permalink).select{ |s| s.id != space.id }.count > 0 or
            User.where(:login => space.permalink).count > 0

        Rails.logger.info "Creating a new permalink for the space " + space.name
        suffix = "-#{counter += 1}"
        new_value = "#{base[0..limit-suffix.size-1]}#{suffix}"
        space.update_attribute(:permalink, new_value)
        Rails.logger.info "* Trying " + space.permalink
      end
    end

  end

  def self.down
  end

end
