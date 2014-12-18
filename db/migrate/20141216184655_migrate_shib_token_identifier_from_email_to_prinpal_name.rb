class MigrateShibTokenIdentifierFromEmailToPrinpalName < ActiveRecord::Migration
  def up
    if should_run_migration
      ShibToken.all.each do |token|
        ShibToken.migrate_identifier_field(token, email_field, principal_name_field)
      end
    end
  end

  def down
    if should_run_migration
      ShibToken.all.each do |token|
        ShibToken.migrate_identifier_field(token, principal_name_field, email_field)
      end
    end
  end

  private
  def should_run_migration
    if shib_enabled && email_field.present? && principal_name_field.present?
      true
    else
      puts "* You don't seem to have shibolleth configured. This migration will be skipped."
      puts "* If you indeed have shibolleth configured please read this page https://github.com/mconf/mconf-web/wiki/Migrating-Shibboleth-users"
      false
    end
  end

  def shib_enabled
    Site.current.shib_email_field
  end

  def email_field
    Site.current.shib_email_field
  end

  def principal_name_field
    Site.current.shib_principal_name_field
  end
end
