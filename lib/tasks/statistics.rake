require 'tasks/support/statistics_helper'
require 'garb'
require 'yaml'

namespace :statistics do

  # matched urls will be grouped using the first capture (the content
  # matched inside the parenthesis)
  RULES = [ '(^/bigbluebutton/servers/[^/]+)',
            '(^/bigbluebutton/servers/[^/]+/rooms/[^/]+)',
            '(^/feedback)',
            '(^/invitations)',
            '(^/invite)',
            '(^/spaces/[^/]+)',
            '(^/users/[^/]+)' ]

  desc "Resets the Statistics table with data from google analytics"
  task :init => :environment do
    Statistic.destroy_all
    stats = StatisticsHelper.get_statistics(Date.parse("10/01/2009"), Date.today, RULES)
    StatisticsHelper.update_statistics_table(stats)
  end

  desc "Updates the Statistics table with data from google analytics"
  task :update => :environment do
    stats = StatisticsHelper.get_statistics(Date.yesterday, Date.today, RULES)
    StatisticsHelper.update_statistics_table(stats)
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
