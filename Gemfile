source "https://rubygems.org"

gem 'activesupport', '>= 7.0.8'
gem "cocoapods", '=  1.16.2'
gem "fastlane", '= 2.220.0'
gem "xcov"
gem 'logger'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
