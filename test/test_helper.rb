if ENV['CI_FLAG']
  # require 'codeclimate-test-reporter'
  # CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require_relative '../lib/hoopscrape'
