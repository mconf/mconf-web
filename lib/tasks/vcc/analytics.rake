require 'garb' 

#dos metodos uno que llena la base de datos con la informacion inicial y otro que actualiza la info desde hace x horas, desde el último update que tendre apuntado en algún lado quizá

namespace :vcc do
  desc "Connection with Google Analytics to get usage statistics"
  task :init_statistics => :environment do
    Statistic.destroy_all
    get_statistics_and_update_table(Date.parse("10/01/2009"),Date.today)
  end
  
  task :update_statistics => :environment do
    get_statistics_and_update_table(Date.yesterday,Date.today)
  end


  def get_statistics_and_update_table(start_date, end_date)
    profile = garb_login
    #we ask for 100.000 last visits, if we have more we should use a higher number in limit
    report = Garb::Report.new(profile, :start_date => Date.parse("10/01/2009"), :end_date => Date.today, :limit =>100000)
    report.metrics :unique_pageviews
    report.dimensions :page_path
    #we do not use filters because then it is Google the one filtering, we ask for all the data and we will filter it
    #report.filters :page_path.contains => 'belief'
    results = report.results  #with this line we get the report, an array of openStruct objects that we will parse
    final_results = compose_final_hash(results)
    update_statistics_table(final_results)
  end


  #method to add the different urls to sum up the visits
  def compose_final_hash(results)
   final_hash = Hash.new
   for res in results
     path = res.page_path
     if path.match('/spaces/[\w-]+')
       resource_url = path.match('/spaces/[\w-]+')[0]
       final_hash["#{resource_url}"] = res.unique_pageviews.to_i + (final_hash["#{resource_url}"] ? final_hash["#{resource_url}"]:0)
     end
     if path.match('/spaces/[\w-]+/events/[\w-]+')
       resource_url = path.match('/spaces/[\w-]+/events/[\w-]+')[0]
       final_hash["#{resource_url}"] = res.unique_pageviews.to_i + (final_hash["#{resource_url}"] ? final_hash["#{resource_url}"]:0)
     end
     if path.match('/spaces/[\w-]+/events/[\w-]+\?show_video=')
       the_id = path[path.index("=")+1,path.length]
       if numeric?(the_id)
         resource_url = path.match('/spaces/[\w-]*')[0] + "/videos/" + the_id.to_s
         final_hash["#{resource_url}"] = res.unique_pageviews.to_i + (final_hash["#{resource_url}"] ? final_hash["#{resource_url}"]:0)
       end
     end
     if path.match('/spaces/[\w-]+/videos/[0-9]+')
       resource_url = path
       final_hash["#{resource_url}"] = res.unique_pageviews.to_i + (final_hash["#{resource_url}"] ? final_hash["#{resource_url}"]:0)
     end
   end 
   final_hash
  end


  #method to introduce in the statistics table the results
  #if the url exist in the table we add the new value, because those are new visits
  def update_statistics_table(final_results)
    final_results.each do |key,value|
      sta = Statistic.find_by_url(key)
      if sta
        sta.unique_pageviews = sta.unique_pageviews + value
      else
        sta = Statistic.new
        sta.url = key
        sta.unique_pageviews = value
      end
      sta.save
    end
    puts "Statistics table updated"
  end


  def garb_login
    Garb::Session.login('plazaglobal@gmail.com', 'isabel2005')
    profile = Garb::Profile.first('UA-12096965-1')
  end


  def numeric?(object)
    true if Float(object) rescue false
  end
end
