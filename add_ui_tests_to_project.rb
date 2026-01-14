#!/usr/bin/env ruby
# Script to add CloudSyncAppUITests target to the Xcode project.pbxproj
# This creates a proper UI test bundle target with all necessary configurations

require 'securerandom'

def generate_uuid
  SecureRandom.hex(12).upcase
end

project_file = 'CloudSyncApp.xcodeproj/project.pbxproj'
content = File.read(project_file)

# Generate UUIDs for each file and target component
# File references
uitests_base_file_ref = generate_uuid
dashboard_uitests_file_ref = generate_uuid
filebrowser_uitests_file_ref = generate_uuid
transfer_uitests_file_ref = generate_uuid
tasks_uitests_file_ref = generate_uuid
workflow_uitests_file_ref = generate_uuid

# Build file references
uitests_base_build_ref = generate_uuid
dashboard_uitests_build_ref = generate_uuid
filebrowser_uitests_build_ref = generate_uuid
transfer_uitests_build_ref = generate_uuid
tasks_uitests_build_ref = generate_uuid
workflow_uitests_build_ref = generate_uuid

# Product and target references
uitests_product_ref = generate_uuid
uitests_target_ref = generate_uuid
uitests_group_ref = generate_uuid

# Build phases
uitests_sources_phase = generate_uuid
uitests_frameworks_phase = generate_uuid
uitests_resources_phase = generate_uuid

# Configuration list and configurations
uitests_config_list = generate_uuid
uitests_debug_config = generate_uuid
uitests_release_config = generate_uuid

# Container item proxy and target dependency
uitests_container_proxy = generate_uuid
uitests_target_dependency = generate_uuid

# 1. Add PBXBuildFile entries
build_files = <<-BUILD
		#{uitests_base_build_ref} /* CloudSyncAppUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{uitests_base_file_ref} /* CloudSyncAppUITests.swift */; };
		#{dashboard_uitests_build_ref} /* DashboardUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{dashboard_uitests_file_ref} /* DashboardUITests.swift */; };
		#{filebrowser_uitests_build_ref} /* FileBrowserUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{filebrowser_uitests_file_ref} /* FileBrowserUITests.swift */; };
		#{transfer_uitests_build_ref} /* TransferViewUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{transfer_uitests_file_ref} /* TransferViewUITests.swift */; };
		#{tasks_uitests_build_ref} /* TasksUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{tasks_uitests_file_ref} /* TasksUITests.swift */; };
		#{workflow_uitests_build_ref} /* WorkflowUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = #{workflow_uitests_file_ref} /* WorkflowUITests.swift */; };
BUILD

content.sub!(/\/\* End PBXBuildFile section \*\//, "#{build_files}/* End PBXBuildFile section */")

# 2. Add PBXContainerItemProxy for UI tests
container_proxy = <<-PROXY
		#{uitests_container_proxy} /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 40 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = 30;
			remoteInfo = CloudSyncApp;
		};
PROXY

content.sub!(/\/\* End PBXContainerItemProxy section \*\//, "#{container_proxy}/* End PBXContainerItemProxy section */")

# 3. Add PBXFileReference entries
file_refs = <<-FILES
		#{uitests_base_file_ref} /* CloudSyncAppUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CloudSyncAppUITests.swift; sourceTree = "<group>"; };
		#{dashboard_uitests_file_ref} /* DashboardUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DashboardUITests.swift; sourceTree = "<group>"; };
		#{filebrowser_uitests_file_ref} /* FileBrowserUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FileBrowserUITests.swift; sourceTree = "<group>"; };
		#{transfer_uitests_file_ref} /* TransferViewUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TransferViewUITests.swift; sourceTree = "<group>"; };
		#{tasks_uitests_file_ref} /* TasksUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TasksUITests.swift; sourceTree = "<group>"; };
		#{workflow_uitests_file_ref} /* WorkflowUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WorkflowUITests.swift; sourceTree = "<group>"; };
		#{uitests_product_ref} /* CloudSyncAppUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = CloudSyncAppUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
FILES

content.sub!(/\/\* End PBXFileReference section \*\//, "#{file_refs}/* End PBXFileReference section */")

# 4. Add PBXFrameworksBuildPhase for UI tests
frameworks_phase = <<-FRAMEWORKS
		#{uitests_frameworks_phase} /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
FRAMEWORKS

content.sub!(/\/\* End PBXFrameworksBuildPhase section \*\//, "#{frameworks_phase}/* End PBXFrameworksBuildPhase section */")

# 5. Add PBXGroup for UI tests
uitests_group = <<-GROUP
		#{uitests_group_ref} /* CloudSyncAppUITests */ = {
			isa = PBXGroup;
			children = (
				#{uitests_base_file_ref} /* CloudSyncAppUITests.swift */,
				#{dashboard_uitests_file_ref} /* DashboardUITests.swift */,
				#{filebrowser_uitests_file_ref} /* FileBrowserUITests.swift */,
				#{transfer_uitests_file_ref} /* TransferViewUITests.swift */,
				#{tasks_uitests_file_ref} /* TasksUITests.swift */,
				#{workflow_uitests_file_ref} /* WorkflowUITests.swift */,
			);
			path = CloudSyncAppUITests;
			sourceTree = "<group>";
		};
GROUP

content.sub!(/\/\* End PBXGroup section \*\//, "#{uitests_group}/* End PBXGroup section */")

# 6. Add UI tests group to main group (G0)
content.sub!(/G0 = \{\s*isa = PBXGroup;\s*children = \(\s*21 \/\* CloudSyncApp \*\/,/m,
  "G0 = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t21 /* CloudSyncApp */,\n\t\t\t\t#{uitests_group_ref} /* CloudSyncAppUITests */,")

# 7. Add UI tests product to Products group
content.sub!(/22 \/\* Products \*\/ = \{\s*isa = PBXGroup;\s*children = \(\s*15 \/\* CloudSyncApp\.app \*\/,/m,
  "22 /* Products */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n\t\t\t\t15 /* CloudSyncApp.app */,\n\t\t\t\t#{uitests_product_ref} /* CloudSyncAppUITests.xctest */,")

# 8. Add PBXNativeTarget for UI tests
native_target = <<-TARGET
		#{uitests_target_ref} /* CloudSyncAppUITests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = #{uitests_config_list} /* Build configuration list for PBXNativeTarget "CloudSyncAppUITests" */;
			buildPhases = (
				#{uitests_sources_phase} /* Sources */,
				#{uitests_frameworks_phase} /* Frameworks */,
				#{uitests_resources_phase} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				#{uitests_target_dependency} /* PBXTargetDependency */,
			);
			name = CloudSyncAppUITests;
			productName = CloudSyncAppUITests;
			productReference = #{uitests_product_ref} /* CloudSyncAppUITests.xctest */;
			productType = "com.apple.product-type.bundle.ui-testing";
		};
TARGET

content.sub!(/\/\* End PBXNativeTarget section \*\//, "#{native_target}/* End PBXNativeTarget section */")

# 9. Add UI test target to project targets list
content.sub!(/targets = \(\s*30 \/\* CloudSyncApp \*\/,\s*55F640B72D68E056E66DC19C \/\* CloudSyncAppTests \*\/,\s*\);/m,
  "targets = (\n\t\t\t\t30 /* CloudSyncApp */,\n\t\t\t\t55F640B72D68E056E66DC19C /* CloudSyncAppTests */,\n\t\t\t\t#{uitests_target_ref} /* CloudSyncAppUITests */,\n\t\t\t);")

# 10. Add PBXResourcesBuildPhase for UI tests
resources_phase = <<-RESOURCES
		#{uitests_resources_phase} /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
RESOURCES

content.sub!(/\/\* End PBXResourcesBuildPhase section \*\//, "#{resources_phase}/* End PBXResourcesBuildPhase section */")

# 11. Add PBXSourcesBuildPhase for UI tests
sources_phase = <<-SOURCES
		#{uitests_sources_phase} /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				#{uitests_base_build_ref} /* CloudSyncAppUITests.swift in Sources */,
				#{dashboard_uitests_build_ref} /* DashboardUITests.swift in Sources */,
				#{filebrowser_uitests_build_ref} /* FileBrowserUITests.swift in Sources */,
				#{transfer_uitests_build_ref} /* TransferViewUITests.swift in Sources */,
				#{tasks_uitests_build_ref} /* TasksUITests.swift in Sources */,
				#{workflow_uitests_build_ref} /* WorkflowUITests.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
SOURCES

content.sub!(/\/\* End PBXSourcesBuildPhase section \*\//, "#{sources_phase}/* End PBXSourcesBuildPhase section */")

# 12. Add PBXTargetDependency for UI tests
target_dependency = <<-DEPENDENCY
		#{uitests_target_dependency} /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = 30 /* CloudSyncApp */;
			targetProxy = #{uitests_container_proxy} /* PBXContainerItemProxy */;
		};
DEPENDENCY

content.sub!(/\/\* End PBXTargetDependency section \*\//, "#{target_dependency}/* End PBXTargetDependency section */")

# 13. Add XCBuildConfiguration for UI tests (Debug and Release)
build_configs = <<-CONFIGS
		#{uitests_debug_config} /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGNING_REQUIRED = NO;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGN_STYLE = Automatic;
				DEVELOPMENT_TEAM = "";
				EXPANDED_CODE_SIGN_IDENTITY = "";
				GENERATE_INFOPLIST_FILE = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
					"@loader_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.CloudSyncAppUITests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
				TEST_TARGET_NAME = CloudSyncApp;
			};
			name = Debug;
		};
		#{uitests_release_config} /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CODE_SIGN_IDENTITY = "-";
				CODE_SIGN_STYLE = Automatic;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
					"@loader_path/../Frameworks",
				);
				MACOSX_DEPLOYMENT_TARGET = 14.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.CloudSyncAppUITests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = macosx;
				SWIFT_VERSION = 5.0;
				TEST_TARGET_NAME = CloudSyncApp;
			};
			name = Release;
		};
CONFIGS

content.sub!(/\/\* End XCBuildConfiguration section \*\//, "#{build_configs}/* End XCBuildConfiguration section */")

# 14. Add XCConfigurationList for UI tests
config_list = <<-CONFIGLIST
		#{uitests_config_list} /* Build configuration list for PBXNativeTarget "CloudSyncAppUITests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				#{uitests_debug_config} /* Debug */,
				#{uitests_release_config} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
CONFIGLIST

content.sub!(/\/\* End XCConfigurationList section \*\//, "#{config_list}/* End XCConfigurationList section */")

# Write the modified content back
File.write(project_file, content)

puts "Successfully added CloudSyncAppUITests target to Xcode project!"
puts ""
puts "UI Test Target Added with:"
puts "  - CloudSyncAppUITests.swift (Base class with helpers)"
puts "  - DashboardUITests.swift (Dashboard view tests)"
puts "  - FileBrowserUITests.swift (File browser tests)"
puts "  - TransferViewUITests.swift (Transfer view tests)"
puts "  - TasksUITests.swift (Tasks view tests)"
puts "  - WorkflowUITests.swift (End-to-end workflow tests)"
puts ""
puts "Target Configuration:"
puts "  - Product Type: UI Testing Bundle"
puts "  - Test Target: CloudSyncApp"
puts "  - Deployment Target: macOS 14.0"
puts ""
puts "Run UI tests with:"
puts "  xcodebuild test -project CloudSyncApp.xcodeproj -scheme CloudSyncApp -destination 'platform=macOS' -only-testing:CloudSyncAppUITests"
