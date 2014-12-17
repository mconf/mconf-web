namespace :shib do

  desc "Migrate shibolleth token identifiers from one field to another"
  task :migrate_tokens, [:old_field, :new_field] => :environment do |t, args|
    old_field, new_field = args[:old_field], args[:new_field]

    if old_field.present? && new_field.present?
      ShibToken.all.each do |token|
        ShibToken.migrate_identifier_field(token, old_field, new_field)
      end
    else
      puts "Call this task like this:\n\t rake shib:migrate_tokens[old_field,new_field]"
    end
  end
end
