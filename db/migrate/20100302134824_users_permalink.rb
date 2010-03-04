class UsersPermalink < ActiveRecord::Migration
  def self.up
    add_column :profiles, :full_name, :string
    Profile.record_timestamps = false
    User.record_timestamps = false
    Profile.reset_column_information

    User.all.each do |u|
      u.profile!.update_attribute :full_name, u.login
      u.update_attribute :login, u.__send__(:create_permalink_for, [:full_name])
    end
  end

  def self.down
    User.record_timestamps = false
    User.all.each do |u|
      u.update_attribute :login, u.profile!.full_name
    end

    remove_column :profiles, :full_name
  end
end
