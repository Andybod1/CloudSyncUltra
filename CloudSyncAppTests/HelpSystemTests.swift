//
//  HelpSystemTests.swift
//  CloudSyncAppTests
//
//  Unit tests for Help System (#52)
//  Tests HelpTopic, HelpCategory, and search functionality
//

import XCTest
@testable import CloudSyncApp

/// Tests for HelpTopic model and search functionality (#52)
final class HelpTopicTests: XCTestCase {

    // MARK: - Test Fixtures

    private func makeSampleTopic(
        title: String = "Getting Started Guide",
        content: String = "Learn how to set up CloudSync Ultra.",
        category: HelpCategory = .gettingStarted,
        keywords: [String] = ["setup", "install", "begin"],
        sortOrder: Int = 0,
        relatedTopicIds: [UUID]? = nil
    ) -> HelpTopic {
        return HelpTopic(
            title: title,
            content: content,
            category: category,
            keywords: keywords,
            sortOrder: sortOrder,
            relatedTopicIds: relatedTopicIds
        )
    }

    // MARK: - TC-52.1: Encoding/Decoding Tests

    /// TC-52.1.1: Model encodes to JSON correctly - P0
    func testHelpTopicEncodesToJSON() throws {
        // Given: HelpTopic with all fields populated
        let topic = makeSampleTopic()

        // When: Encoded to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(topic)

        // Then: Should produce valid JSON
        XCTAssertNotNil(data)
        XCTAssertGreaterThan(data.count, 0, "Encoded data should not be empty")

        // Verify JSON contains expected fields
        let jsonString = String(data: data, encoding: .utf8)!
        XCTAssertTrue(jsonString.contains("title"), "JSON should contain title field")
        XCTAssertTrue(jsonString.contains("content"), "JSON should contain content field")
        XCTAssertTrue(jsonString.contains("category"), "JSON should contain category field")
    }

    /// TC-52.1.2: Model decodes from JSON correctly - P0
    func testHelpTopicDecodesFromJSON() throws {
        // Given: Valid JSON representing a HelpTopic
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "title": "Test Topic",
            "content": "Test content here",
            "category": "getting_started",
            "keywords": ["test", "demo"],
            "sortOrder": 1,
            "relatedTopicIds": null
        }
        """
        let data = json.data(using: .utf8)!

        // When: Decoded from JSON
        let decoder = JSONDecoder()
        let topic = try decoder.decode(HelpTopic.self, from: data)

        // Then: Should produce valid HelpTopic
        XCTAssertEqual(topic.title, "Test Topic")
        XCTAssertEqual(topic.content, "Test content here")
        XCTAssertEqual(topic.category, .gettingStarted)
        XCTAssertEqual(topic.keywords, ["test", "demo"])
        XCTAssertEqual(topic.sortOrder, 1)
        XCTAssertNil(topic.relatedTopicIds)
    }

    /// TC-52.1.3: Encode then decode produces identical object - P0
    func testHelpTopicRoundTrip() throws {
        // Given: HelpTopic with all fields populated
        let relatedIds = [UUID(), UUID()]
        let original = HelpTopic(
            title: "Complete Guide",
            content: "Full content with details about cloud sync operations.",
            category: .syncing,
            keywords: ["sync", "cloud", "transfer"],
            sortOrder: 5,
            relatedTopicIds: relatedIds
        )

        // When: Encoded to JSON then decoded back
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(HelpTopic.self, from: data)

        // Then: Original and decoded topics are equal
        XCTAssertEqual(original.id, decoded.id, "ID should match")
        XCTAssertEqual(original.title, decoded.title, "Title should match")
        XCTAssertEqual(original.content, decoded.content, "Content should match")
        XCTAssertEqual(original.category, decoded.category, "Category should match")
        XCTAssertEqual(original.keywords, decoded.keywords, "Keywords should match")
        XCTAssertEqual(original.sortOrder, decoded.sortOrder, "Sort order should match")
        XCTAssertEqual(original.relatedTopicIds, decoded.relatedTopicIds, "Related topic IDs should match")
    }

    /// TC-52.1.4: relatedTopicIds encodes as null when nil - P1
    func testHelpTopicOptionalRelatedTopicsEncode() throws {
        // Given: Topic with nil relatedTopicIds
        let topic = makeSampleTopic(relatedTopicIds: nil)

        // When: Encoded to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(topic)
        let jsonString = String(data: data, encoding: .utf8)!

        // Then: Should encode successfully (null or omitted)
        XCTAssertNotNil(data)
        // Decode back to verify nil handling
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(HelpTopic.self, from: data)
        XCTAssertNil(decoded.relatedTopicIds, "relatedTopicIds should remain nil after round trip")
    }

    /// TC-52.1.5: Array of topics encodes correctly - P1
    func testHelpTopicArrayEncoding() throws {
        // Given: Array of HelpTopics
        let topics = [
            makeSampleTopic(title: "Topic 1"),
            makeSampleTopic(title: "Topic 2"),
            makeSampleTopic(title: "Topic 3")
        ]

        // When: Encoded to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(topics)

        // Then: Should produce valid JSON array
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([HelpTopic].self, from: data)
        XCTAssertEqual(decoded.count, 3, "Should decode all 3 topics")
        XCTAssertEqual(decoded[0].title, "Topic 1")
        XCTAssertEqual(decoded[1].title, "Topic 2")
        XCTAssertEqual(decoded[2].title, "Topic 3")
    }

    // MARK: - TC-52.2: Initialization Tests

    /// TC-52.2.1: Default initializer provides sensible defaults - P1
    func testHelpTopicDefaultValues() {
        // When: Creating topic with minimal parameters
        let topic = HelpTopic(
            title: "Minimal Topic",
            content: "Some content",
            category: .gettingStarted
        )

        // Then: Default values should be sensible
        XCTAssertEqual(topic.keywords, [], "Default keywords should be empty array")
        XCTAssertEqual(topic.sortOrder, 0, "Default sortOrder should be 0")
        XCTAssertNil(topic.relatedTopicIds, "Default relatedTopicIds should be nil")
    }

    /// TC-52.2.2: Each topic gets unique UUID - P1
    func testHelpTopicUUIDGeneration() {
        // When: Creating multiple topics
        let topic1 = makeSampleTopic()
        let topic2 = makeSampleTopic()
        let topic3 = makeSampleTopic()

        // Then: Each should have unique UUID
        XCTAssertNotEqual(topic1.id, topic2.id, "Topics should have unique IDs")
        XCTAssertNotEqual(topic2.id, topic3.id, "Topics should have unique IDs")
        XCTAssertNotEqual(topic1.id, topic3.id, "Topics should have unique IDs")
    }

    /// TC-52.2.3: All parameters accepted - P0
    func testHelpTopicFullInitialization() {
        // Given: All parameters
        let id = UUID()
        let relatedIds = [UUID(), UUID()]

        // When: Creating with all parameters
        let topic = HelpTopic(
            id: id,
            title: "Full Topic",
            content: "Full content",
            category: .advanced,
            keywords: ["key1", "key2", "key3"],
            sortOrder: 10,
            relatedTopicIds: relatedIds
        )

        // Then: All values should be set
        XCTAssertEqual(topic.id, id)
        XCTAssertEqual(topic.title, "Full Topic")
        XCTAssertEqual(topic.content, "Full content")
        XCTAssertEqual(topic.category, .advanced)
        XCTAssertEqual(topic.keywords, ["key1", "key2", "key3"])
        XCTAssertEqual(topic.sortOrder, 10)
        XCTAssertEqual(topic.relatedTopicIds, relatedIds)
    }

    // MARK: - TC-52.3: Basic Search Tests

    /// TC-52.3.1: Query matching title returns true - P0
    func testSearchMatchesTitle() {
        // Given: HelpTopic with title "Getting Started Guide"
        let topic = makeSampleTopic(title: "Getting Started Guide")

        // When: matches(query: "getting started")
        let result = topic.matches(query: "getting started")

        // Then: returns true
        XCTAssertTrue(result, "Should match title")
    }

    /// TC-52.3.2: Query matching content returns true - P0
    func testSearchMatchesContent() {
        // Given: HelpTopic with specific content
        let topic = makeSampleTopic(content: "Learn how to configure your cloud provider settings.")

        // When: searching for content text
        let result = topic.matches(query: "cloud provider")

        // Then: returns true
        XCTAssertTrue(result, "Should match content")
    }

    /// TC-52.3.3: Query matching keyword returns true - P0
    func testSearchMatchesKeyword() {
        // Given: HelpTopic with keywords
        let topic = makeSampleTopic(keywords: ["sync", "transfer", "backup"])

        // When: searching for keyword
        let result = topic.matches(query: "backup")

        // Then: returns true
        XCTAssertTrue(result, "Should match keyword")
    }

    /// TC-52.3.4: Non-matching query returns false - P0
    func testSearchNoMatch() {
        // Given: HelpTopic
        let topic = makeSampleTopic(
            title: "Getting Started",
            content: "Learn basics",
            keywords: ["setup"]
        )

        // When: searching for unrelated term
        let result = topic.matches(query: "encryption")

        // Then: returns false
        XCTAssertFalse(result, "Should not match unrelated query")
    }

    /// TC-52.3.5: Search is case-insensitive - P0
    func testSearchCaseInsensitive() {
        // Given: HelpTopic with title "Sync Files"
        let topic = makeSampleTopic(title: "Sync Files")

        // When: matches(query: "SYNC") OR matches(query: "sync") OR matches(query: "SyNc")
        let resultUppercase = topic.matches(query: "SYNC")
        let resultLowercase = topic.matches(query: "sync")
        let resultMixedCase = topic.matches(query: "SyNc")

        // Then: All return true
        XCTAssertTrue(resultUppercase, "Uppercase query should match")
        XCTAssertTrue(resultLowercase, "Lowercase query should match")
        XCTAssertTrue(resultMixedCase, "Mixed case query should match")
    }

    // MARK: - TC-52.4: Partial Match Search Tests

    /// TC-52.4.1: Partial title match works - P1
    func testSearchPartialTitleMatch() {
        // Given: Topic with longer title
        let topic = makeSampleTopic(title: "Complete Configuration Guide")

        // When: Searching with partial match
        let result = topic.matches(query: "config")

        // Then: Should match
        XCTAssertTrue(result, "Partial title match should work")
    }

    /// TC-52.4.2: Partial keyword match works - P1
    func testSearchPartialKeywordMatch() {
        // Given: Topic with keywords
        let topic = makeSampleTopic(keywords: ["synchronization", "configuration"])

        // When: Searching with partial keyword
        let result = topic.matches(query: "sync")

        // Then: Should match
        XCTAssertTrue(result, "Partial keyword match should work")
    }

    /// TC-52.4.3: Single character search works - P2
    func testSearchSingleCharacter() {
        // Given: Topic with title containing 's'
        let topic = makeSampleTopic(title: "Sync Files")

        // When: Searching for single character
        let result = topic.matches(query: "s")

        // Then: Should match
        XCTAssertTrue(result, "Single character search should work")
    }

    // MARK: - TC-52.7: Keyword Matching Tests

    /// TC-52.7.1: Exact keyword match found - P0
    func testKeywordExactMatch() {
        // Given: Topic with specific keywords
        let topic = makeSampleTopic(keywords: ["backup", "restore", "sync"])

        // When: Searching for exact keyword
        let result = topic.matches(query: "backup")

        // Then: Should find match
        XCTAssertTrue(result, "Exact keyword should match")
    }

    /// TC-52.7.2: Partial keyword match found - P1
    func testKeywordPartialMatch() {
        // Given: Topic with keyword "synchronization"
        let topic = makeSampleTopic(keywords: ["synchronization"])

        // When: Searching with partial match
        let result = topic.matches(query: "synchro")

        // Then: Should find match
        XCTAssertTrue(result, "Partial keyword should match")
    }

    /// TC-52.7.3: Any matching keyword is found - P1
    func testMultipleKeywordsAnyMatch() {
        // Given: Topic with multiple keywords
        let topic = makeSampleTopic(keywords: ["alpha", "beta", "gamma"])

        // When: Searching for middle keyword
        let result = topic.matches(query: "beta")

        // Then: Should find match
        XCTAssertTrue(result, "Should match any keyword in list")
    }

    /// TC-52.7.4: Empty keywords array handled - P1
    func testEmptyKeywordsArray() {
        // Given: Topic with empty keywords
        let topic = makeSampleTopic(keywords: [])

        // When: Searching (relying on title/content)
        let resultTitle = topic.matches(query: "Getting")
        let resultMiss = topic.matches(query: "xyznonexistent")

        // Then: Should not crash, and title should still match
        XCTAssertTrue(resultTitle, "Title should still match with empty keywords")
        XCTAssertFalse(resultMiss, "Unrelated query should not match")
    }

    // MARK: - TC-52.8: Relevance Scoring Tests

    /// TC-52.8.1: Title match scores higher than content - P0
    func testTitleMatchHigherThanContent() {
        // Given: Two HelpTopics
        // Topic A: title contains "sync", content does not
        let topicA = HelpTopic(
            title: "How to Sync Files",
            content: "This guide explains file transfers.",
            category: .syncing,
            keywords: []
        )
        // Topic B: title does not contain "sync", content does
        let topicB = HelpTopic(
            title: "Transfer Guide",
            content: "Learn how to sync your data across devices.",
            category: .syncing,
            keywords: []
        )

        // When: relevanceScore(for: "sync") called on both
        let scoreA = topicA.relevanceScore(for: "sync")
        let scoreB = topicB.relevanceScore(for: "sync")

        // Then: Topic A score > Topic B score
        XCTAssertGreaterThan(scoreA, scoreB, "Title match should score higher than content match")
    }

    /// TC-52.8.2: Exact title match gets bonus - P1
    func testExactTitleMatchHighest() {
        // Given: Topic with exact title match
        let exactMatch = HelpTopic(
            title: "sync",
            content: "Description",
            category: .syncing,
            keywords: []
        )
        let partialMatch = HelpTopic(
            title: "How to Sync",
            content: "Description",
            category: .syncing,
            keywords: []
        )

        // When: Calculating scores
        let exactScore = exactMatch.relevanceScore(for: "sync")
        let partialScore = partialMatch.relevanceScore(for: "sync")

        // Then: Exact match should score higher
        XCTAssertGreaterThan(exactScore, partialScore, "Exact title match should get bonus")
    }

    /// TC-52.8.3: Keyword match between title and content - P1
    func testKeywordMatchMediumScore() {
        // Given: Topic with keyword match only
        let keywordOnly = HelpTopic(
            title: "Getting Started",
            content: "Learn the basics",
            category: .gettingStarted,
            keywords: ["synchronization"]
        )

        // When: Searching for keyword
        let score = keywordOnly.relevanceScore(for: "synchronization")

        // Then: Should have positive score (keyword score is 50+)
        XCTAssertGreaterThanOrEqual(score, 50, "Keyword match should have medium score")
    }

    /// TC-52.8.4: Content match scores lowest - P1
    func testContentMatchLowestScore() {
        // Given: Topic with content match only
        let contentOnly = HelpTopic(
            title: "Guide",
            content: "Learn about encryption features",
            category: .security,
            keywords: []
        )

        // When: Calculating score for content match
        let score = contentOnly.relevanceScore(for: "encryption")

        // Then: Should have low but positive score (content score is 10)
        XCTAssertEqual(score, 10, "Content-only match should score 10")
    }

    /// TC-52.8.5: Non-match returns 0 - P1
    func testNoMatchZeroScore() {
        // Given: Topic
        let topic = makeSampleTopic(
            title: "Guide",
            content: "Learn basics",
            keywords: ["setup"]
        )

        // When: Searching for non-matching term
        let score = topic.relevanceScore(for: "xyznonexistent")

        // Then: Should return 0
        XCTAssertEqual(score, 0, "Non-match should return 0 score")
    }

    // MARK: - Hashable/Equatable Tests

    func testHelpTopicHashableByID() {
        // Given: Two topics with same ID
        let id = UUID()
        let topic1 = HelpTopic(id: id, title: "Topic 1", content: "Content 1", category: .gettingStarted)
        let topic2 = HelpTopic(id: id, title: "Topic 2", content: "Content 2", category: .advanced)

        // When: Used in Set
        var set = Set<HelpTopic>()
        set.insert(topic1)
        set.insert(topic2)

        // Then: Should be treated as same (by ID)
        XCTAssertEqual(set.count, 1, "Topics with same ID should be equal in Set")
    }

    func testHelpTopicEquatableByID() {
        // Given: Two topics with same ID
        let id = UUID()
        let topic1 = HelpTopic(id: id, title: "Topic 1", content: "Content 1", category: .gettingStarted)
        let topic2 = HelpTopic(id: id, title: "Topic 2", content: "Content 2", category: .advanced)

        // Then: Should be equal
        XCTAssertEqual(topic1, topic2, "Topics with same ID should be equal")
    }
}

// MARK: - HelpCategory Tests

/// Tests for HelpCategory enum (#52)
final class HelpCategoryTests: XCTestCase {

    // MARK: - TC-52.5: HelpCategory Tests

    /// TC-52.5.1: All 6 categories defined - P0
    func testAllCategoriesExist() {
        // Given: HelpCategory enum

        // When: Checking allCases
        let allCategories = HelpCategory.allCases

        // Then: Contains all expected categories
        XCTAssertEqual(allCategories.count, 6, "Should have exactly 6 categories")

        let categoryNames = Set(allCategories.map { $0.rawValue })
        XCTAssertTrue(categoryNames.contains("getting_started"), "Should have gettingStarted")
        XCTAssertTrue(categoryNames.contains("providers"), "Should have providers")
        XCTAssertTrue(categoryNames.contains("syncing"), "Should have syncing")
        XCTAssertTrue(categoryNames.contains("troubleshooting"), "Should have troubleshooting")
        XCTAssertTrue(categoryNames.contains("security"), "Should have security")
        XCTAssertTrue(categoryNames.contains("advanced"), "Should have advanced")
    }

    /// TC-52.5.2: Each category has display name - P0
    func testCategoryDisplayNames() {
        // Given: All categories

        // Then: Each should have non-empty display name
        for category in HelpCategory.allCases {
            XCTAssertFalse(category.displayName.isEmpty, "\(category) should have display name")
        }

        // Verify specific display names
        XCTAssertEqual(HelpCategory.gettingStarted.displayName, "Getting Started")
        XCTAssertEqual(HelpCategory.providers.displayName, "Cloud Providers")
        XCTAssertEqual(HelpCategory.syncing.displayName, "Syncing & Transfers")
        XCTAssertEqual(HelpCategory.troubleshooting.displayName, "Troubleshooting")
        XCTAssertEqual(HelpCategory.security.displayName, "Security & Encryption")
        XCTAssertEqual(HelpCategory.advanced.displayName, "Advanced Features")
    }

    /// TC-52.5.3: Each category has icon - P1
    func testCategoryIconNames() {
        // Given: All categories

        // Then: Each should have non-empty icon name
        for category in HelpCategory.allCases {
            XCTAssertFalse(category.iconName.isEmpty, "\(category) should have icon name")
        }

        // Verify icons are SF Symbols (contain "." in name pattern)
        XCTAssertTrue(HelpCategory.gettingStarted.iconName.contains("."), "Icon should be SF Symbol")
        XCTAssertEqual(HelpCategory.gettingStarted.iconName, "play.circle.fill")
        XCTAssertEqual(HelpCategory.providers.iconName, "cloud.fill")
        XCTAssertEqual(HelpCategory.syncing.iconName, "arrow.triangle.2.circlepath")
        XCTAssertEqual(HelpCategory.troubleshooting.iconName, "wrench.and.screwdriver.fill")
        XCTAssertEqual(HelpCategory.security.iconName, "lock.shield.fill")
        XCTAssertEqual(HelpCategory.advanced.iconName, "gearshape.2.fill")
    }

    /// TC-52.5.4: Categories sorted correctly - P1
    func testCategorySortOrder() {
        // Given: All categories

        // Then: Sort orders should be sequential starting from 0
        XCTAssertEqual(HelpCategory.gettingStarted.sortOrder, 0)
        XCTAssertEqual(HelpCategory.providers.sortOrder, 1)
        XCTAssertEqual(HelpCategory.syncing.sortOrder, 2)
        XCTAssertEqual(HelpCategory.troubleshooting.sortOrder, 3)
        XCTAssertEqual(HelpCategory.security.sortOrder, 4)
        XCTAssertEqual(HelpCategory.advanced.sortOrder, 5)

        // Verify sorting
        let sorted = HelpCategory.allCases.sorted { $0.sortOrder < $1.sortOrder }
        XCTAssertEqual(sorted[0], .gettingStarted)
        XCTAssertEqual(sorted[5], .advanced)
    }

    /// TC-52.5.5: Category encodes/decodes properly - P0
    func testCategoryEncodeDecode() throws {
        // Given: A category
        let original = HelpCategory.troubleshooting

        // When: Encoded and decoded
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(HelpCategory.self, from: data)

        // Then: Should match
        XCTAssertEqual(original, decoded)
    }

    // MARK: - TC-52.6: Filtering by Category Tests

    /// TC-52.6.1: Returns only matching category - P0
    func testFilterTopicsByCategory() {
        // Given: Array of topics in different categories
        let topics = [
            HelpTopic(title: "Start 1", content: "Content", category: .gettingStarted),
            HelpTopic(title: "Provider 1", content: "Content", category: .providers),
            HelpTopic(title: "Start 2", content: "Content", category: .gettingStarted),
            HelpTopic(title: "Security 1", content: "Content", category: .security)
        ]

        // When: Filtering by gettingStarted
        let filtered = topics.filter { $0.category == .gettingStarted }

        // Then: Should return only gettingStarted topics
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { $0.category == .gettingStarted })
    }

    /// TC-52.6.2: Empty category returns empty - P1
    func testFilterEmptyCategoryReturnsEmpty() {
        // Given: Array of topics (none in .advanced)
        let topics = [
            HelpTopic(title: "Start 1", content: "Content", category: .gettingStarted),
            HelpTopic(title: "Provider 1", content: "Content", category: .providers)
        ]

        // When: Filtering by category with no topics
        let filtered = topics.filter { $0.category == .advanced }

        // Then: Should return empty array
        XCTAssertEqual(filtered.count, 0)
    }

    /// TC-52.6.3: Can filter by multiple categories - P2
    func testFilterMultipleCategories() {
        // Given: Array of topics
        let topics = [
            HelpTopic(title: "Start 1", content: "Content", category: .gettingStarted),
            HelpTopic(title: "Provider 1", content: "Content", category: .providers),
            HelpTopic(title: "Security 1", content: "Content", category: .security)
        ]

        // When: Filtering by multiple categories
        let targetCategories: Set<HelpCategory> = [.gettingStarted, .security]
        let filtered = topics.filter { targetCategories.contains($0.category) }

        // Then: Should return topics from both categories
        XCTAssertEqual(filtered.count, 2)
    }

    // MARK: - Identifiable Tests

    func testCategoryIdentifiable() {
        // Given: A category
        let category = HelpCategory.syncing

        // Then: id should equal rawValue
        XCTAssertEqual(category.id, category.rawValue)
        XCTAssertEqual(category.id, "syncing")
    }

    // MARK: - All Categories Coverage

    func testAllCategoriesHaveCompleteImplementation() {
        for category in HelpCategory.allCases {
            // Each category should have all required properties
            XCTAssertFalse(category.id.isEmpty, "\(category) missing id")
            XCTAssertFalse(category.displayName.isEmpty, "\(category) missing displayName")
            XCTAssertFalse(category.iconName.isEmpty, "\(category) missing iconName")
            XCTAssertGreaterThanOrEqual(category.sortOrder, 0, "\(category) invalid sortOrder")
        }
    }
}
