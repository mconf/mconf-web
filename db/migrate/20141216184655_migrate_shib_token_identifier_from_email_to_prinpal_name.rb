class MigrateShibTokenIdentifierFromEmailToPrinpalName < ActiveRecord::Migration
  def up
    ShibToken.all.each do |token|
      old_identifier = token.identifier
      identifier = token.data['Shib-eduPerson-eduPersonPrincipalName']
      if identifier.present? && token.update_attributes(identifier: identifier)
        puts "* Migrating token ##{token.id} identifier from email '#{old_identifier}' to eduPersonPrincipalName '#{token.identifier}'"
      end
    end
  end

  def down
    ShibToken.all.each do |token|
      old_identifier = token.identifier
      identifier = token.data[Site.current.shib_email_field]
      if identifier.present? && token.update_attributes(identifier: identifier)
        puts "* Migrating token ##{token.id} identifier from eduPersonPrincipalName '#{old_identifier}' to email '#{token.identifier}'"
      end
    end
  end
end
