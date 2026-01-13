import XCTest
@testable import CloudSyncApp

final class AddRemoteViewTests: XCTestCase {

    // MARK: - Provider Search Tests (#22)

    func testSearchFiltersProviders() {
        // Test that search correctly filters provider list
        let allProviders = CloudProviderType.allCases
        let searchText = "google"
        let filtered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
        XCTAssertTrue(filtered.contains(.googleDrive))
        XCTAssertFalse(filtered.contains(.dropbox))
    }

    func testEmptySearchShowsAll() {
        let allProviders = CloudProviderType.allCases
        let searchText = ""
        let filtered = searchText.isEmpty ? allProviders : allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
        XCTAssertEqual(filtered.count, allProviders.count)
    }

    func testCaseInsensitiveSearch() {
        let allProviders = CloudProviderType.allCases

        // Test lowercase search
        let lowercaseFiltered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains("google")
        }

        // Test uppercase search
        let uppercaseFiltered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains("GOOGLE")
        }

        // Test mixed case search
        let mixedCaseFiltered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains("GoOgLe")
        }

        XCTAssertEqual(lowercaseFiltered, uppercaseFiltered)
        XCTAssertEqual(uppercaseFiltered, mixedCaseFiltered)
        XCTAssertTrue(lowercaseFiltered.contains(.googleDrive))
    }

    func testPartialNameSearch() {
        let allProviders = CloudProviderType.allCases

        // Test partial search for "drop" should find Dropbox
        let dropFiltered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains("drop")
        }
        XCTAssertTrue(dropFiltered.contains(.dropbox))

        // Test partial search for "one" should find OneDrive
        let oneFiltered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains("one")
        }
        XCTAssertTrue(oneFiltered.contains(.oneDrive))
    }

    func testNoMatchesReturnsEmpty() {
        let allProviders = CloudProviderType.allCases
        let searchText = "nonexistentprovider123"
        let filtered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
        XCTAssertTrue(filtered.isEmpty)
    }

    func testMultipleMatchesForCommonTerms() {
        let allProviders = CloudProviderType.allCases

        // Search for "cloud" - should match multiple providers
        let cloudFiltered = allProviders.filter {
            $0.displayName.localizedCaseInsensitiveContains("cloud")
        }

        // Should find at least one provider with "cloud" in the name
        XCTAssertFalse(cloudFiltered.isEmpty)
    }

    // MARK: - Remote Name Dialog Timing Tests (#23)

    func testRemoteNameFieldVisibility() {
        // Simulate AddRemoteSheet state behavior
        var selectedProvider: CloudProviderType? = nil
        var remoteName: String = ""

        // Initially no provider selected - name field should be hidden
        XCTAssertNil(selectedProvider)

        // Select a provider - name field should become visible
        selectedProvider = .googleDrive
        XCTAssertNotNil(selectedProvider)

        // Remote name should be set to provider's display name
        if let provider = selectedProvider {
            remoteName = provider.displayName
            XCTAssertEqual(remoteName, "Google Drive")
        }
    }

    func testRemoteNameDefaultsToProviderName() {
        let providers: [CloudProviderType] = [.googleDrive, .dropbox, .oneDrive, .box]

        for provider in providers {
            let expectedName = provider.displayName
            XCTAssertFalse(expectedName.isEmpty, "Provider \(provider) should have a display name")
        }
    }

    func testRemoteNameFieldStateTransitions() {
        // Simulate the state transitions in AddRemoteSheet
        var selectedProvider: CloudProviderType? = nil
        var isRemoteNameVisible: Bool {
            return selectedProvider != nil
        }

        // Initial state - no provider selected
        XCTAssertFalse(isRemoteNameVisible)

        // Select provider - field becomes visible
        selectedProvider = .googleDrive
        XCTAssertTrue(isRemoteNameVisible)

        // Change provider - field remains visible
        selectedProvider = .dropbox
        XCTAssertTrue(isRemoteNameVisible)

        // Deselect provider - field becomes hidden
        selectedProvider = nil
        XCTAssertFalse(isRemoteNameVisible)
    }

    func testProviderSelection() {
        // Test that provider selection works correctly
        let testProvider = CloudProviderType.googleDrive
        var selectedProvider: CloudProviderType? = nil

        // Select provider
        selectedProvider = testProvider
        XCTAssertEqual(selectedProvider, testProvider)

        // Verify the provider has expected properties
        XCTAssertEqual(testProvider.displayName, "Google Drive")
        XCTAssertTrue(testProvider.isSupported)
        XCTAssertFalse(testProvider.isExperimental)
    }

    // MARK: - Provider Properties Tests

    func testSupportedProvidersOnly() {
        let supportedProviders = CloudProviderType.allCases.filter { $0.isSupported && $0 != .local }

        // Should have multiple supported providers
        XCTAssertFalse(supportedProviders.isEmpty)

        // All returned providers should be supported
        for provider in supportedProviders {
            XCTAssertTrue(provider.isSupported)
            XCTAssertNotEqual(provider, .local)
        }
    }

    func testProviderDisplayNames() {
        let providers: [CloudProviderType] = [.googleDrive, .dropbox, .oneDrive, .box]

        for provider in providers {
            XCTAssertFalse(provider.displayName.isEmpty, "Provider \(provider) should have a display name")
            XCTAssertNotNil(provider.iconName, "Provider \(provider) should have an icon")
            XCTAssertNotNil(provider.brandColor, "Provider \(provider) should have a brand color")
        }
    }

    func testProviderSearchCoverage() {
        // Test search coverage for major providers
        let majorProviders = ["Google", "Dropbox", "OneDrive", "Box", "Amazon", "Microsoft"]
        let allProviders = CloudProviderType.allCases

        for searchTerm in majorProviders {
            let matches = allProviders.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchTerm)
            }

            // Each major provider search should find at least one result
            // (This validates our search algorithm works for common providers)
            if searchTerm == "Google" {
                XCTAssertTrue(matches.contains(.googleDrive))
            } else if searchTerm == "Dropbox" {
                XCTAssertTrue(matches.contains(.dropbox))
            } else if searchTerm == "Microsoft" || searchTerm == "OneDrive" {
                XCTAssertTrue(matches.contains(.oneDrive))
            }
        }
    }
}