namespace :jobs do

  desc "Returns the number of queued jobs (delayed_job)"
  task :queued => :environment do
    puts "Queued jobs: " + ActiveRecord::Base.connection.execute("select * from delayed_jobs").count.to_s
  end

end
