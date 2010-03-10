namespace :station do
  namespace :sources do
    desc "Import all sources"
    task :import => :environment do
      Source.all.each(&:import)
    end
  end
end

