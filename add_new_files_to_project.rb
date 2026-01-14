#!/usr/bin/env ruby
# Script to add new files to the Xcode project.pbxproj
# Adds: OnboardingManager, OnboardingView, WelcomeStepView, HelpManager, HelpCategory, HelpTopic
# And test files: OnboardingManagerTests, HelpSystemTests, MultiThreadDownloadTests, TransferOptimizerTests

require 'securerandom'

def generate_uuid
  SecureRandom.hex(12).upcase
end

project_file = 'CloudSyncApp.xcodeproj/project.pbxproj'
content = File.read(project_file)

# Generate UUIDs for each new file
# Main target files
onboarding_manager_file_ref = generate_uuid
onboarding_manager_build_ref = generate_uuid

onboarding_view_file_ref = generate_uuid
onboarding_view_build_ref = generate_uuid

welcome_step_view_file_ref = generate_uuid
welcome_step_view_build_ref = generate_uuid

help_manager_file_ref = generate_uuid
help_manager_build_ref = generate_uuid

help_category_file_ref = generate_uuid
help_category_build_ref = generate_uuid

help_topic_file_ref = generate_uuid
help_topic_build_ref = generate_uuid

# Onboarding group
onboarding_group_ref = generate_uuid

# Test target files
onboarding_tests_file_ref = generate_uuid
onboarding_tests_build_ref = generate_uuid

help_tests_file_ref = generate_uuid
help_tests_build_ref = generate_uuid

multithread_tests_file_ref = generate_uuid
multithread_tests_build_ref = generate_uuid

optimizer_tests_file_ref = generate_uuid
optimizer_tests_build_ref = generate_uuid

# 1. Add PBXBuildFile entries (after existing build files section)
build_files = <<-BUILD

		#{onboarding_manager_build_ref} /* OnboardingManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{onboarding_manager_file_ref} /* OnboardingManager.swift */; };
		#{onboarding_view_build_ref} /* OnboardingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{onboarding_view_file_ref} /* OnboardingView.swift */; };
		#{welcome_step_view_build_ref} /* WelcomeStepView.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{welcome_step_view_file_ref} /* WelcomeStepView.swift */; };
		#{help_manager_build_ref} /* HelpManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{help_manager_file_ref} /* HelpManager.swift */; };
		#{help_category_build_ref} /* HelpCategory.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{help_category_file_ref} /* HelpCategory.swift */; };
		#{help_topic_build_ref} /* HelpTopic.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{help_topic_file_ref} /* HelpTopic.swift */; };
		#{onboarding_tests_build_ref} /* OnboardingManagerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{onboarding_tests_file_ref} /* OnboardingManagerTests.swift */; };
		#{help_tests_build_ref} /* HelpSystemTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{help_tests_file_ref} /* HelpSystemTests.swift */; };
		#{multithread_tests_build_ref} /* MultiThreadDownloadTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{multithread_tests_file_ref} /* MultiThreadDownloadTests.swift */; };
		#{optimizer_tests_build_ref} /* TransferOptimizerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{optimizer_tests_file_ref} /* TransferOptimizerTests.swift */; };
BUILD

content.sub!(/\/\* End PBXBuildFile section \*\//, "#{build_files}/* End PBXBuildFile section */")

# 2. Add PBXFileReference entries
file_refs = <<-FILES
		#{onboarding_manager_file_ref} /* OnboardingManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = OnboardingManager.swift; path = CloudSyncApp/ViewModels/OnboardingManager.swift; sourceTree = SOURCE_ROOT; };
		#{onboarding_view_file_ref} /* OnboardingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = OnboardingView.swift; path = CloudSyncApp/Views/Onboarding/OnboardingView.swift; sourceTree = SOURCE_ROOT; };
		#{welcome_step_view_file_ref} /* WelcomeStepView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = WelcomeStepView.swift; path = CloudSyncApp/Views/Onboarding/WelcomeStepView.swift; sourceTree = SOURCE_ROOT; };
		#{help_manager_file_ref} /* HelpManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = HelpManager.swift; path = CloudSyncApp/HelpManager.swift; sourceTree = SOURCE_ROOT; };
		#{help_category_file_ref} /* HelpCategory.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = HelpCategory.swift; path = CloudSyncApp/Models/HelpCategory.swift; sourceTree = SOURCE_ROOT; };
		#{help_topic_file_ref} /* HelpTopic.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = HelpTopic.swift; path = CloudSyncApp/Models/HelpTopic.swift; sourceTree = SOURCE_ROOT; };
		#{onboarding_tests_file_ref} /* OnboardingManagerTests.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = CloudSyncAppTests/OnboardingManagerTests.swift; sourceTree = SOURCE_ROOT; };
		#{help_tests_file_ref} /* HelpSystemTests.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = CloudSyncAppTests/HelpSystemTests.swift; sourceTree = SOURCE_ROOT; };
		#{multithread_tests_file_ref} /* MultiThreadDownloadTests.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = CloudSyncAppTests/MultiThreadDownloadTests.swift; sourceTree = SOURCE_ROOT; };
		#{optimizer_tests_file_ref} /* TransferOptimizerTests.swift */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = sourcecode.swift; path = CloudSyncAppTests/TransferOptimizerTests.swift; sourceTree = SOURCE_ROOT; };
FILES

content.sub!(/\/\* End PBXFileReference section \*\//, "#{file_refs}/* End PBXFileReference section */")

# 3. Add Onboarding group to Views group (G3)
# First create the Onboarding group definition
onboarding_group = <<-GROUP
		#{onboarding_group_ref} /* Onboarding */ = {
			isa = PBXGroup;
			children = (
				#{onboarding_view_file_ref} /* OnboardingView.swift */,
				#{welcome_step_view_file_ref} /* WelcomeStepView.swift */,
			);
			path = Onboarding;
			sourceTree = "<group>";
		};
GROUP

# Insert the group definition before /* End PBXGroup section */
content.sub!(/\/\* End PBXGroup section \*\//, "#{onboarding_group}/* End PBXGroup section */")

# 4. Add OnboardingManager to ViewModels group (G2)
content.sub!(/G2 \/\* ViewModels \*\/ = \{\s*isa = PBXGroup;\s*children = \(/m,
  "G2 /* ViewModels */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t#{onboarding_manager_file_ref} /* OnboardingManager.swift */,")

# 5. Add HelpCategory and HelpTopic to Models group (G1)
content.sub!(/G1 \/\* Models \*\/ = \{\s*isa = PBXGroup;\s*children = \(/m,
  "G1 /* Models */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t#{help_category_file_ref} /* HelpCategory.swift */,\n\t\t\t\t#{help_topic_file_ref} /* HelpTopic.swift */,")

# 6. Add Onboarding group to Views group (G3)
content.sub!(/G3 \/\* Views \*\/ = \{\s*isa = PBXGroup;\s*children = \(/m,
  "G3 /* Views */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t#{onboarding_group_ref} /* Onboarding */,")

# 7. Add HelpManager to main CloudSyncApp group (21)
# Insert after ProtonDriveManager.swift
content.sub!(/3EA943E5A37C52E2869C48D0 \/\* ProtonDriveManager\.swift \*\/,\s*\);/m,
  "3EA943E5A37C52E2869C48D0 /* ProtonDriveManager.swift */,\n\t\t\t\t#{help_manager_file_ref} /* HelpManager.swift */,\n\t\t\t);")

# 8. Add test files to CloudSyncAppTests group (1BFB43019B5CF02DA3491D14)
content.sub!(/5106C877AA4817D4F7C064FC \/\* RemoteReorderingTests\.swift \*\/,\s*\);/m,
  "5106C877AA4817D4F7C064FC /* RemoteReorderingTests.swift */,\n\t\t\t\t#{onboarding_tests_file_ref} /* OnboardingManagerTests.swift */,\n\t\t\t\t#{help_tests_file_ref} /* HelpSystemTests.swift */,\n\t\t\t\t#{multithread_tests_file_ref} /* MultiThreadDownloadTests.swift */,\n\t\t\t\t#{optimizer_tests_file_ref} /* TransferOptimizerTests.swift */,\n\t\t\t);")

# 9. Add source files to main target Sources build phase (32)
# Insert after SV01 /* SchedulesView.swift in Sources */
content.sub!(/SV01 \/\* SchedulesView\.swift in Sources \*\/,\s*\);/m,
  "SV01 /* SchedulesView.swift in Sources */,\n\t\t\t\t#{onboarding_manager_build_ref} /* OnboardingManager.swift in Sources */,\n\t\t\t\t#{onboarding_view_build_ref} /* OnboardingView.swift in Sources */,\n\t\t\t\t#{welcome_step_view_build_ref} /* WelcomeStepView.swift in Sources */,\n\t\t\t\t#{help_manager_build_ref} /* HelpManager.swift in Sources */,\n\t\t\t\t#{help_category_build_ref} /* HelpCategory.swift in Sources */,\n\t\t\t\t#{help_topic_build_ref} /* HelpTopic.swift in Sources */,\n\t\t\t);")

# 10. Add test files to test target Sources build phase (63D93C4BEA6FB47024EBDA7D)
# Insert after RemoteReorderingTests.swift
content.sub!(/7C5F9037D207CCDFBE127ED0 \/\* RemoteReorderingTests\.swift in Sources \*\/,\s*\);/m,
  "7C5F9037D207CCDFBE127ED0 /* RemoteReorderingTests.swift in Sources */,\n\t\t\t\t#{onboarding_tests_build_ref} /* OnboardingManagerTests.swift in Sources */,\n\t\t\t\t#{help_tests_build_ref} /* HelpSystemTests.swift in Sources */,\n\t\t\t\t#{multithread_tests_build_ref} /* MultiThreadDownloadTests.swift in Sources */,\n\t\t\t\t#{optimizer_tests_build_ref} /* TransferOptimizerTests.swift in Sources */,\n\t\t\t);")

# Write the modified content back
File.write(project_file, content)

puts "Successfully added files to Xcode project!"
puts ""
puts "Main Target Files Added:"
puts "  - OnboardingManager.swift (ViewModels)"
puts "  - OnboardingView.swift (Views/Onboarding)"
puts "  - WelcomeStepView.swift (Views/Onboarding)"
puts "  - HelpManager.swift (CloudSyncApp)"
puts "  - HelpCategory.swift (Models)"
puts "  - HelpTopic.swift (Models)"
puts ""
puts "Test Target Files Added:"
puts "  - OnboardingManagerTests.swift"
puts "  - HelpSystemTests.swift"
puts "  - MultiThreadDownloadTests.swift"
puts "  - TransferOptimizerTests.swift"
