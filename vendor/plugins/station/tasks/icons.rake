# Use Oxygen icons from oxygen-icon-theme package
#
# Create config/icons-oxygen.yml configuration file.
# Example in examples/config/icons-oxygen.yml
namespace :station do
  namespace :icons do
    namespace :oxygen do
      desc "Copy oxygen icons from source_dir to destination_dir"
      task :copy do
        icons = YAML.load_file("#{ RAILS_ROOT }/config/icons-oxygen.yml")

        # Mimetypes
        #
        # Copy each one to resource_sizes
        icons['mime_types'].each do |mime_type|
          print "."
          icons['resource_sizes'].each do |size|
            command = "cp "
            command += File.join(icons['source_dir'], "#{ size }x#{ size }", "mimetypes", mime_type)
            command += " "
            command += File.join(RAILS_ROOT, icons['destination_dir'], size.to_s)

            system command
          end
        end

        # Resources
        #
        # Use an icon for each resource
        icons['resources'].each do |resource|
          resource['size'] ||= icons['resource_sizes']
          print "."

          resource['size'].each do |size|
            command = "cp "
            command += File.join(icons['source_dir'], "#{ size }x#{ size }", resource['dir'], resource['file'])
            command += " "
            command += File.join(RAILS_ROOT, icons['destination_dir'], size.to_s, resource['name'])

            system command
          end
        end

        # New Resources
        #
        # Use icons for new resources
        icons['new_resources'].each do |resource|
          resource['new-name'] = resource['name'] + '-new.png'
          resource['size'] ||= [ 16 ]
          print "."

          resource['size'].each do |size|
            command = "cp "
            command += File.join(icons['source_dir'], "#{ size }x#{ size }", resource['dir'], resource['file'])
            command += " "
            command += File.join(RAILS_ROOT, icons['destination_dir'], size.to_s, resource['new-name'])

            system command
          end
        end

        puts
      end
    end
  end
end
