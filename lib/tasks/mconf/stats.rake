namespace :mconf do

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
    # puts "#{ I18n.t(klass.to_s.underscore, :count => :other) }:"
    # puts "\tTotal: #{ klass.count }"

    # Create a Hash like stats_hash[year][month] = 0
    stats_hash = Hash.new{ |h, year| h[year] = Hash.new{ |year, month| year[month] = 0 } }

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
    output_file = ENV['OUTPUT']
    if ENV['OUTPUT']
      File.open(ENV['OUTPUT'], "a") do |file|
        file.write(text)
      end
    else
      print(text)
    end
  end
end
