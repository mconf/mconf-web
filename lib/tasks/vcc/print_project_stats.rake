require 'garb' 

#tarea para atacar a google analytics y ver si hay comunidades activas en los últimos dos meses, eventos realizados, etc

namespace :vcc do
  desc "Connection with Google Analytics to get usage statistics"
  task :print_project_stats => :environment do
    get_statistics(Date.parse("08/01/2010"),Date.today)
  end
  

  def get_statistics(start_date, end_date)
    profile = garb_login
    #we ask for 100.000 last visits, if we have more we should use a higher number in limit
    report = Garb::Report.new(profile, :start_date => start_date, :end_date => end_date, :limit =>100000)
    report.metrics :unique_pageviews
    report.dimensions :page_path
    results = report.results  #with this line we get the report, an array of openStruct objects that we will parse
    final_results = compose_final_hash(results)
    print_results(final_results) 
  end

  #method to print the results
  def print_results(results)
   profile = garb_login
   report = Garb::Report.new(profile, :start_date => Date.parse("08/01/2009"), :end_date => Date.today, :limit =>100000)
   report.metrics :new_visits
   results = report.results
   puts "Number of unique visitors of the site: " + results[0].new_visits
   puts "Number of spaces with more than 50 unique pageviews in the last 2 months:"
   puts @space_with_more_than_50_visits.size
   @space_with_more_than_50_visits.each do |key, value|
     puts key + "  " + value.to_s 
   end 

  end
  

  #method to add the different urls to sum up the visits
  def compose_final_hash(results)
   final_hash = Hash.new
   @space_with_more_than_50_visits = Hash.new
   for res in results
     path = res.page_path
     if path.match('/spaces/[\w-]+')
       resource_url = path.match('/spaces/[\w-]+')[0]
       u_pag_views = res.unique_pageviews.to_i + (final_hash["#{resource_url}"] ? final_hash["#{resource_url}"]:0)
       final_hash["#{resource_url}"] = u_pag_views
       if(u_pag_views>50)
         @space_with_more_than_50_visits["#{resource_url}"] = u_pag_views
       end
     end
   end 
   final_hash
  end

  def garb_login
    myhash = YAML.load_file("#{RAILS_ROOT}/config/google_user_passwd.yml")
    user = myhash["user"]
    pass = myhash["passwd"]
    agent = myhash["agent"]
    Garb::Session.login(user, pass)
    profile = Garb::Profile.first(agent)
  end


  def numeric?(object)
    true if Float(object) rescue false
  end
end
