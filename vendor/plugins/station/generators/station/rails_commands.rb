Rails::Generator::Commands::Create.class_eval do
  def route_root
    sentinel = 'ActionController::Routing::Routes.draw do |map|'

    logger.route "root"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{ match }\n  map.root :controller => 'sites', :action => 'show'\n"
      end
    end
  end
end

Rails::Generator::Commands::Destroy.class_eval do
  def route_root
    look_for = "\n  map.root :controller => 'sites', :action => 'show'\n"

    logger.route "root"
    unless options[:pretend]
      gsub_file 'config/routes.rb', /(#{Regexp.escape(look_for)})/mi, ''
    end
 end
end

Rails::Generator::Commands::List.class_eval do
  def route_cms
    logger.route "CMS"
  end
end
