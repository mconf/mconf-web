class ShibToken < ActiveRecord::Base
  belongs_to :user
  validates :identifier, :presence => true, :uniqueness => true
  validates :user_id, :presence => true, :uniqueness => true

  serialize :data, Hash

  def user_with_disabled
    User.with_disabled.where(id: self.user_id).first
  end

  def self.user_created_via_shib? u
    ShibToken.where(user_id: u.id, :new_account => true).present?
  end

  def self.migrate_identifier_field(token, old_field, new_field)
    old_identifier = token.identifier
    identifier = token.data[new_field]
    if identifier.present? && token.update_attributes(identifier: identifier)
      puts "* Migrating token ##{token.id} identifier from #{old_field} '#{old_identifier}' to #{new_field} '#{token.identifier}'"
    else
      puts "* Failed to migrate token ##{token.id} '#{token.errors.full_messages.join(",")}'"
    end
  end
end
