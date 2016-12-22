#!/usr/bin/env ruby
require 'net/http'
require 'optparse'
require 'json'
require 'fileutils'

g_languages = ["es_419", "de", "ru", "bg"] # how they are called in Transifex
g_uri_resources = 'http://www.transifex.com/api/2/project/mconf-web/resources/'
g_uri_translation = 'http://www.transifex.com/api/2/project/mconf-web/resource/%%RES%%/translation/%%LANG%%/?mode=default&file'
g_locales_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'locales'))

puts "Languages requested: " + g_languages.to_s

# Parse arguments
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: transifex.rb [options]"
  opts.on("-u", "--user [user:password]", String, "user:password as in curl") do |v|
    vals = v.split(":")
    options[:user] = vals[0]
    options[:pass] = vals[1]
  end
end.parse!


# Get the list of resources available
uri_resources = URI(g_uri_resources)
req = Net::HTTP::Get.new(uri_resources)
req.basic_auth options[:user], options[:pass]
res = Net::HTTP.start(uri_resources.hostname, uri_resources.port) { |http|
  http.request(req)
}

begin
  resources = JSON.parse!(res.body)
rescue JSON::ParserError => e
  # will catch authentication errors mostly
  abort res.body
end

puts "Resources found: #{resources.map{ |r| r["name"] }}"

g_languages.each do |language|
  FileUtils.mkdir_p(File.join(g_locales_path, language))

  resources.each do |resource|
    uri_download = URI(g_uri_translation.gsub("%%RES%%", resource['slug']).gsub("%%LANG%%", language))
    language_on_mconf = language.gsub('_', '-').downcase
    filename = File.join(g_locales_path, language_on_mconf, resource['name'])
    puts "Downloading translation #{uri_download} into #{filename}"

    # download the file and save it
    Net::HTTP.start(uri_download.hostname, uri_download.port) do |http|
      req = Net::HTTP::Get.new(uri_download)
      req.basic_auth options[:user], options[:pass]
      res = http.request(req)
      open(filename, "w") do |file|
        content = res.body.sub(language, language_on_mconf) # only the first match
        file.write(content)
      end
    end

    sleep 1 # be nice with Transifex
  end
end
