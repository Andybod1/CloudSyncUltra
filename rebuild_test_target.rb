#!/usr/bin/env ruby
# encoding: UTF-8
# Script to rebuild test target with only working test files

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

project_path = '/Users/antti/Claude/CloudSyncApp.xcodeproj'
tests_folder = '/Users/antti/Claude/CloudSyncAppTests'

# Open the project
project = Xcodeproj::Project.open(project_path)

# Find and remove existing test target
test_target = project.targets.find { |t| t.name == 'CloudSyncAppTests' }
if test_target
  puts "Removing existing test target..."
  test_target.remove_from_project
end

# Find and remove existing test group
test_group = project.main_group['CloudSyncAppTests']
if test_group
  puts "Removing existing test group..."
  test_group.remove_from_project
end

# Get the main app target
main_target = project.targets.find { |t| t.name == 'CloudSyncApp' }

# Create new test target
test_target = project.new_target(:unit_test_bundle, 'CloudSyncAppTests', :osx)
test_target.add_dependency(main_target)

# Create the test group
test_group = project.main_group.new_group('CloudSyncAppTests')
test_group.set_source_tree('SOURCE_ROOT')
test_group.set_path('CloudSyncAppTests')

# Get all swift test files (excluding .disabled)
test_files = Dir.glob("#{tests_folder}/*.swift").reject { |f| f.include?('.disabled') }

puts "Adding #{test_files.count} test files..."

# Add test files to the target
test_files.each do |file_path|
  file_name = File.basename(file_path)
  file_ref = test_group.new_reference(file_name)
  file_ref.set_source_tree('SOURCE_ROOT')
  file_ref.set_path("CloudSyncAppTests/#{file_name}")
  test_target.source_build_phase.add_file_reference(file_ref)
  puts "  Added: #{file_name}"
end

# Configure build settings
test_target.build_configurations.each do |config|
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CloudSyncApp.app/Contents/MacOS/CloudSyncApp'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.yourcompany.CloudSyncAppTests'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['CODE_SIGN_IDENTITY'] = '-'  # Ad-hoc signing
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/../Frameworks', '@loader_path/../Frameworks']
  config.build_settings['ENABLE_TESTABILITY'] = 'YES'
end

# Enable testability on main target
main_target.build_configurations.each do |config|
  config.build_settings['ENABLE_TESTABILITY'] = 'YES'
end

# Save
project.save

puts "\n✅ Test target rebuilt with #{test_files.count} files!"
