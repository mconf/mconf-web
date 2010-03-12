class StationScaffoldGenerator < ScaffoldGenerator
  def banner
    "Usage: #{$0} station_scaffold ModelName [field:type, field:type]"
  end

  def scaffold_views
    %w[ ]
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, and test directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      m.template 'index.html.erb', File.join('app/views', controller_class_path, controller_file_name, "index.html.erb")
      m.template 'show.html.erb', File.join('app/views', controller_class_path, controller_file_name, "show.html.erb")
      m.template 'show.erb', File.join('app/views', controller_class_path, controller_file_name, "_#{ singular_name }.html.erb")
      m.template 'new.html.erb', File.join('app/views', controller_class_path, controller_file_name, "new.html.erb")
      m.template 'edit.html.erb', File.join('app/views', controller_class_path, controller_file_name, "edit.html.erb")
      m.template 'form.erb', File.join('app/views', controller_class_path, controller_file_name, "_form.html.erb")
      m.template 'index.atom.builder', File.join('app/views', controller_class_path, controller_file_name, "index.atom.builder")
      m.template 'partial.atom.builder', File.join('app/views', controller_class_path, controller_file_name, "_#{ singular_name }.atom.builder")

      m.dependency 'model', [name] + @args, :collision => :skip
      #FIXME: we should reopen the file and add acts_as_content method
      m.template 'model.rb', File.join('app/models', class_path, "#{ file_name }.rb"), :collision => :force

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
    end
  end
end
