#!/usr/bin/env ruby
# Script to add SettingsUITests.swift to the CloudSyncAppUITests target

require 'securerandom'

def generate_uuid
  SecureRandom.hex(12).upcase
end

project_file = 'CloudSyncApp.xcodeproj/project.pbxproj'
content = File.read(project_file)

# Generate UUIDs for the new file
settings_uitests_file_ref = generate_uuid
settings_uitests_build_ref = generate_uuid

# 1. Add PBXBuildFile entry
build_file = <<-BUILD
		#{settings_uitests_build_ref} /* SettingsUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{settings_uitests_file_ref} /* SettingsUITests.swift */; };
BUILD

content.sub!(/\/\* End PBXBuildFile section \*\//, "#{build_file}/* End PBXBuildFile section */")

# 2. Add PBXFileReference entry
file_ref = <<-FILES
		#{settings_uitests_file_ref} /* SettingsUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SettingsUITests.swift; sourceTree = "<group>"; };
FILES

content.sub!(/\/\* End PBXFileReference section \*\//, "#{file_ref}/* End PBXFileReference section */")

# 3. Add to CloudSyncAppUITests group (find the group and add to children)
# Look for the WorkflowUITests.swift entry and add after it
content.sub!(/WorkflowUITests\.swift \*\/,\s*\);(\s*path = CloudSyncAppUITests;)/m,
  "WorkflowUITests.swift */,\n\t\t\t\t#{settings_uitests_file_ref} /* SettingsUITests.swift */,\n\t\t\t);\n\\1")

# 4. Add to UI tests Sources build phase
# Find the last entry in the UI tests sources phase and add after it
content.sub!(/WorkflowUITests\.swift in Sources \*\/,\s*\);(\s*runOnlyForDeploymentPostprocessing = 0;\s*\};)/m,
  "WorkflowUITests.swift in Sources */,\n\t\t\t\t#{settings_uitests_build_ref} /* SettingsUITests.swift in Sources */,\n\t\t\t);\n\\1")

# Write the modified content back
File.write(project_file, content)

puts "Successfully added SettingsUITests.swift to CloudSyncAppUITests target!"
