class MigrateShibTokenIdentifierFromEmailToPrinpalName < ActiveRecord::Migration
  def up
    case migration_type
    when :no_eppn_field
      Site.current.update_attribute(:shib_principal_name_field, email_field)
    when :email_and_eppn
      ShibToken.all.each do |token|
        ShibToken.migrate_identifier_field(token, email_field, principal_name_field)
      end
    else
      puts_warning
    end
  end

  def down
    case migration_type
    # when :no_eppn_field # EPPN was empty or equal to email_field, so leave as it is
    when :email_and_eppn
      ShibToken.all.each do |token|
        ShibToken.migrate_identifier_field(token, principal_name_field, email_field)
      end
    else
      puts_warning
    end
  end

  private

  def migration_type
    if shib_enabled
      if email_field.present?
        if principal_name_field.present?
          if principal_name_field == email_field
            :no_eppn_field
          else
            :email_and_eppn
          end
        else
          :no_eppn_field
        end
      end
    else
      :none
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

  def puts_warning
    puts "* You don't seem to have shibolleth configured. This migration will be skipped."
    puts "* If you indeed have shibolleth configured please read this page https://github.com/mconf/mconf-web/wiki/Shibboleth:-migrate-users-to-use-EPPN"
  end
end
