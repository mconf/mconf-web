namespace :shib do

  desc "Migrate shibolleth token identifiers from one field to another. See https://github.com/mconf/mconf-web/wiki/Shibboleth:-migrate-users-to-use-EPPN"
  task :migrate_tokens, [:old_field, :new_field] => :environment do |t, args|
    old_field, new_field = args[:old_field], args[:new_field]

    if old_field.present? && new_field.present?
      ShibToken.find_each do |token|
        ShibToken.migrate_identifier_field(token, old_field, new_field)
      end
    else
      puts "Missing parameters. Run this task with:\n\trake shib:migrate_tokens[old_field,new_field]"
    end
  end

end
