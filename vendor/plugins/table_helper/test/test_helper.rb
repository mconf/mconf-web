# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../../plugin_test_helper/lib")
require 'rubygems'
require 'plugin_test_helper'

# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

Test::Unit::TestCase.class_eval do
  private
    def assert_html_equal(expected, actual)
      assert_equal expected.strip.gsub(/\n\s*/, ''), actual
    end
end
