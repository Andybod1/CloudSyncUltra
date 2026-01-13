#!/usr/bin/env ruby
# encoding: UTF-8
# Script to fix code signing for test target

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

project_path = '/Users/antti/Claude/CloudSyncApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find both targets
main_target = project.targets.find { |t| t.name == 'CloudSyncApp' }
test_target = project.targets.find { |t| t.name == 'CloudSyncAppTests' }

unless test_target && main_target
  puts "Targets not found!"
  exit 1
end

puts "Fixing code signing settings..."

# Get main target's signing settings
main_team = nil
main_target.build_configurations.each do |config|
  main_team = config.build_settings['DEVELOPMENT_TEAM']
  break if main_team && !main_team.empty?
end

puts "Main target team: #{main_team || '(none)'}"

# Copy signing settings from main to test
test_target.build_configurations.each do |config|
  # Match main target's code signing
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = main_team || ''
  config.build_settings['CODE_SIGN_IDENTITY'] = '-'  # Ad-hoc signing for tests
  
  # Ensure test host is properly set
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CloudSyncApp.app/Contents/MacOS/CloudSyncApp'
  
  puts "  Fixed #{config.name}"
end

# Also ensure main target allows testing
main_target.build_configurations.each do |config|
  config.build_settings['ENABLE_TESTABILITY'] = 'YES'
end

project.save
puts "\n✅ Code signing fixed!"
