# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{table_helper}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Pfeifer"]
  s.date = %q{2009-06-08}
  s.description = %q{Adds a helper method for generating HTML tables from collections in Rails}
  s.email = %q{aaron@pluginaweek.org}
  s.files = ["lib/table_helper.rb", "lib/table_helper", "lib/table_helper/header.rb", "lib/table_helper/body_row.rb", "lib/table_helper/body.rb", "lib/table_helper/cell.rb", "lib/table_helper/footer.rb", "lib/table_helper/html_element.rb", "lib/table_helper/row.rb", "lib/table_helper/collection_table.rb", "test/unit", "test/unit/row_builder_test.rb", "test/unit/body_row_test.rb", "test/unit/html_element_test.rb", "test/unit/collection_table_test.rb", "test/unit/header_test.rb", "test/unit/row_test.rb", "test/unit/body_test.rb", "test/unit/cell_test.rb", "test/unit/footer_test.rb", "test/helpers", "test/helpers/table_helper_test.rb", "test/app_root", "test/app_root/app", "test/app_root/app/models", "test/app_root/app/models/person.rb", "test/app_root/db", "test/app_root/db/migrate", "test/app_root/db/migrate/001_create_people.rb", "test/test_helper.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc"]
  s.has_rdoc = true
  s.homepage = %q{http://www.pluginaweek.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pluginaweek}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Adds a helper method for generating HTML tables from collections in Rails}
  s.test_files = ["test/unit/row_builder_test.rb", "test/unit/body_row_test.rb", "test/unit/html_element_test.rb", "test/unit/collection_table_test.rb", "test/unit/header_test.rb", "test/unit/row_test.rb", "test/unit/body_test.rb", "test/unit/cell_test.rb", "test/unit/footer_test.rb", "test/helpers/table_helper_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
