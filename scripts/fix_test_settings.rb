#!/usr/bin/env ruby
# encoding: UTF-8
# Script to fix test target build settings

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

project_path = '/Users/antti/Claude/CloudSyncApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find test target
test_target = project.targets.find { |t| t.name == 'CloudSyncAppTests' }

unless test_target
  puts "Test target not found!"
  exit 1
end

puts "Fixing build settings for CloudSyncAppTests..."

# Configure build settings
test_target.build_configurations.each do |config|
  # Critical: Link against the app
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CloudSyncApp.app/Contents/MacOS/CloudSyncApp'
  
  # Module settings - important for @testable import
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.yourcompany.CloudSyncAppTests'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  
  # Framework search paths
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/../Frameworks', '@loader_path/../Frameworks']
  
  # Enable testability
  config.build_settings['ENABLE_TESTABILITY'] = 'YES'
  
  puts "  Updated #{config.name} configuration"
end

# Also update main target to enable testability
main_target = project.targets.find { |t| t.name == 'CloudSyncApp' }
if main_target
  main_target.build_configurations.each do |config|
    config.build_settings['ENABLE_TESTABILITY'] = 'YES'
  end
  puts "  Enabled testability on main target"
end

project.save
puts "\n✅ Build settings updated!"
