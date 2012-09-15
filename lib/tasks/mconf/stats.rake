require 'tasks/support/analytics_helper'
require 'garb'
require 'yaml'

namespace :mconf do
  namespace :statistics do

    desc "Global Statistics"
    task :print => :environment do
      %w(User Space Event Post).map(&:constantize).each{ |k| print_stats(k) }
    end

    def print_stats(klass)
      puts "#{ I18n.t(klass.to_s.underscore, :count => :other) }:"
      puts "\tTotal: #{ klass.count }"

      # Create a Hash like stats_hash[year][month] = 0
      stats_hash = Hash.new{ |h, year| h[year] = Hash.new{ |year, month| year[month] = 0 } }

      klass.all.each do |obj|
        stats_hash[obj.created_at.year][obj.created_at.month] += 1
      end

      stats_hash.each_pair do |year, months|
        (1..12).each do |month|
          puts "\t#{year} #{ format("%2d", month) }: #{months[month] }"
        end
      end
    end

    # matched urls will be grouped using the first capture (the content
    # matched inside the parenthesis)
    RULES = [ '(^/bigbluebutton/servers/[^/]+)',
              '(^/bigbluebutton/servers/[^/]+/rooms/[^/]+)',
              '(^/feedback)',
              '(^/invitations)',
              '(^/invite)',
              '(^/spaces/[^/]+)',
              '(^/users/[^/]+)' ]

    desc "Resets the Statistics table with data from google analytics from ENV['FROM'] or yesterday if not set"
    # bundle exec rake mconf:statistics:init FROM=10/01/2010
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
    # bundle exec rake mconf:statistics:update FROM=10/10/2011
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

    desc "Updates the Statistics table with data from google analytics"
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
end
