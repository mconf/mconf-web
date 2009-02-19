namespace :readers do
  desc "Reads the content of all the feeds"
  task(:read => :environment) {
    Reader.find(:all).each do |reader|
      reader.create_news   
    end
  
  }
end