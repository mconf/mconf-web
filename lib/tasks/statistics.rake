# TODO: test everything here and review what is really needed

require 'tasks/support/analytics_helper'
require 'garb'
require 'yaml'

namespace :statistics do

  desc "Global Statistics"
  task :stats => :environment do
    results = {}
    models = %w(User Space Event Post)
    models.map(&:constantize).each do |k|
      results[k.name.to_sym] = get_stats(k)
    end
    print_stats(models, results)
  end

  def get_stats(klass)
    # Create a Hash like stats_hash[year][month] = 0
    stats_hash = Hash.new{ |h, year| h[year] = Hash.new{ |year2, month| year2[month] = 0 } }

    klass.all.each do |obj|
      unless obj.created_at.nil?
        stats_hash[obj.created_at.year][obj.created_at.month] += 1
      end
    end

    stats_hash
  end

  def print_stats(models, results)

    if ENV['OUTPUT']
      puts "Output will be at #{ENV['OUTPUT']}"
    end

    # get min and max year
    max_year = 0
    min_year = Time.now.year
    models.each do |model|
      stats_hash = results[model.to_sym]
      stats_hash.each_pair do |year, months|
        if year > max_year
          max_year = year
        end
        if year < min_year
          min_year = year
        end
      end
    end

    # header
    output "Year\tMonth"
    models.each do |model|
      output "\t#{model}\t"
    end
    output "\n"

    # one line for each year-month
    sums = {}
    (min_year..max_year).each do |year|
      (1..12).each do |month|
        output "#{year}\t#{month}"
        models.each do |model|
          sums[model.to_sym] ||= 0
          stats_hash = results[model.to_sym]
          sums[model.to_sym] += stats_hash[year][month]
          output "\t#{stats_hash[year][month]}\t#{sums[model.to_sym]}"
        end
        output "\n"
      end
    end
  end

  def output(text)
    if ENV['OUTPUT']
      File.open(ENV['OUTPUT'], "a") do |file|
        file.write(text)
      end
    else
      print(text)
    end
  end

  # matched urls will be grouped using the first capture (the content
  # matched inside the parenthesis)
  RULES = [
    '(^/bigbluebutton/servers/[^/]+)',
    '(^/bigbluebutton/servers/[^/]+/rooms/[^/]+)',
    '(^/feedback)',
    '(^/invitations)',
    '(^/invite)',
    '(^/spaces/[^/]+)',
    '(^/users/[^/]+)'
  ]

  desc "Resets the Statistics table with data from google analytics from ENV['FROM'] or yesterday if not set"
  # bundle exec rake statistics:init FROM=10/01/2010
  task :init => :environment do
    puts "Statistic.destroy_all"
    Statistic.destroy_all

    from = ENV['FROM'] ? Date.parse(ENV['FROM']) : Date.parse("10/01/2010")
    puts "Getting statistics from #{from.to_s} to #{Date.today.to_s}"
    stats = AnalyticsHelper.get_statistics(from, Date.today, RULES)
    AnalyticsHelper.update_statistics_table(stats)

    puts "New statistics:"
    puts "  Total page views: " + Statistic.sum("unique_pageviews").to_s
    puts "              URLs: " + Statistic.count.to_s
  end

  desc "Increments the Statistics table with data from google analytics from ENV['FROM'] or yesterday if not set"
  # bundle exec rake statistics:update FROM=10/10/2011
  task :update => :environment do
    puts "Current statistics:"
    puts "  Total page views: " + Statistic.sum("unique_pageviews").to_s
    puts "              URLs: " + Statistic.count.to_s

    from = ENV['FROM'] ? Date.parse(ENV['FROM']) : Date.yesterday
    puts "Getting statistics from #{from.to_s} to #{Date.today.to_s}"
    stats = AnalyticsHelper.get_statistics(from, Date.today, RULES)
    AnalyticsHelper.update_statistics_table(stats)

    puts "New statistics:"
    puts "  Total page views: " + Statistic.sum("unique_pageviews").to_s
    puts "              URLs: " + Statistic.count.to_s
  end

  desc "Prints the data from the Statistics table"
  task :print => :environment do
    puts "Current statistics (page views):"
    puts "    Total (page views): " + Statistic.sum("unique_pageviews").to_s
    puts "  Average (page views): " + Statistic.average("unique_pageviews").to_s
    puts "  Minimum (page views): " + Statistic.minimum("unique_pageviews").to_s
    puts "  Maximum (page views): " + Statistic.maximum("unique_pageviews").to_s
    puts "                  URLs: " + Statistic.count.to_s
    puts
    puts "Top spaces:"
    Statistic.where(['url LIKE ?', '/spaces/%']).order('unique_pageviews desc').first(5).each do |rec|
      puts "  " + rec.url + " : " + rec.unique_pageviews.to_s
    end
    puts
    puts "Top users:"
    Statistic.where(['url LIKE ?', '/users/%']).order('unique_pageviews desc').first(5).each do |rec|
      puts "  " + rec.url + " : " + rec.unique_pageviews.to_s
    end
    puts
    puts "Top webconf rooms:"
    Statistic.where(['url LIKE ?', '%/rooms/%']).order('unique_pageviews desc').first(5).each do |rec|
      puts "  " + rec.url + " : " + rec.unique_pageviews.to_s
    end
  end

end
