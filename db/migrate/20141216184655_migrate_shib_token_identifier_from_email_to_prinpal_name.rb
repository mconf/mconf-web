class MigrateShibTokenIdentifierFromEmailToPrinpalName < ActiveRecord::Migration
  def up
    ShibToken.all.each do |token|
      ShibToken.migrate_identifier_field(token, email_field, principal_name_field)
    end
  end

  def down
    ShibToken.all.each do |token|
      ShibToken.migrate_identifier_field(token, principal_name_field, email_field)
    end
  end

  private
  def email_field
    Site.current.shib_email_field
  end

  def principal_name_field
    Site.current.shib_principal_name_field
  end
end
