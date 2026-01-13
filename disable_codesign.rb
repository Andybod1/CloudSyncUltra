#!/usr/bin/env ruby
# encoding: UTF-8
# Disable code signing for Debug builds to allow tests to run

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

project_path = '/Users/antti/Claude/CloudSyncApp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "Disabling code signing for Debug builds..."

project.targets.each do |target|
  target.build_configurations.each do |config|
    if config.name == 'Debug'
      # Disable code signing for Debug
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
      puts "  #{target.name} - #{config.name}: Code signing disabled"
    end
  end
end

project.save
puts "\n✅ Code signing disabled for Debug builds!"
