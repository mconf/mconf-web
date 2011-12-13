class StatisticsHelper

  # Gets the data from google analytics and returns a hash with { 'url' => views }
  def self.get_statistics(start_date, end_date, rules)
    profile = garb_login

    # we ask for 1.000.000 last visits, if we have more we should use a higher number in limit
    report = Garb::Report.new(profile, :start_date => start_date, :end_date => end_date, :limit => 100000)
    report.metrics :unique_pageviews
    report.dimensions :page_path
    filter_results(report.results, rules)
  end

  # Updates the db table with the incremental results in 'final_results'
  def self.update_statistics_table(final_results)
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
  end

  private

  # method to add the different urls to sum up the visits
  def self.filter_results(results, rules)
    final_hash = Hash.new

    # try to match each result with each rule
    # the key in the hash is the first capture in the regex match
    # this will group several urls into a single key
    results.each do |res|
      path = res.page_path
      views = res.unique_pageviews.to_i

      rules.each do |rule|
        if path.match(rule)
          key = path.match(rule)[1]
          final_hash[key] = final_hash[key] ? (final_hash[key] + views) : views
        end
      end
   end

   final_hash
  end

  # Creates the garb profile used to access google analytics
  def self.garb_login
    myhash = YAML.load_file("#{Rails.root.to_s}/config/analytics_conf.yml")
    user = myhash["user"]
    pass = myhash["passwd"]
    agent = myhash["agent"]
    Garb::Session.login(user, pass)
    profile = Garb::Profile.first(agent)
  end

end
