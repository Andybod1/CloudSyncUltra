#!/usr/bin/env ruby
# encoding: UTF-8
# Script to add test target to CloudSyncApp Xcode project

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

project_path = '/Users/antti/Claude/CloudSyncApp.xcodeproj'
tests_folder = '/Users/antti/Claude/CloudSyncAppTests'

# Open the project
project = Xcodeproj::Project.open(project_path)

# Check if test target already exists
if project.targets.find { |t| t.name == 'CloudSyncAppTests' }
  puts "Test target already exists!"
  exit 0
end

# Get the main app target
main_target = project.targets.find { |t| t.name == 'CloudSyncApp' }

# Create the test target
test_target = project.new_target(:unit_test_bundle, 'CloudSyncAppTests', :osx)

# Add dependency on main target
test_target.add_dependency(main_target)

# Create or find the test group
test_group = project.main_group.find_subpath('CloudSyncAppTests', true)
test_group.set_source_tree('SOURCE_ROOT')
test_group.set_path('CloudSyncAppTests')

# Get all swift test files
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

# Configure build settings for the test target
test_target.build_configurations.each do |config|
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/CloudSyncApp.app/Contents/MacOS/CloudSyncApp'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.yourcompany.CloudSyncAppTests'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '14.0'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['INFOPLIST_FILE'] = ''
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
end

# Create scheme for tests
scheme = Xcodeproj::XCScheme.new
scheme.add_test_target(test_target)
scheme.add_build_target(main_target)
scheme.save_as(project_path, 'CloudSyncApp')

# Save the project
project.save

puts "\n✅ Test target 'CloudSyncAppTests' added successfully!"
puts "   #{test_files.count} test files included"
