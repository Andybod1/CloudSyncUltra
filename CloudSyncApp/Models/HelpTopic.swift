//
//  HelpTopic.swift
//  CloudSyncApp
//
//  Help topic model representing a help article
//

import Foundation

struct HelpTopic: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var category: HelpCategory
    var keywords: [String]
    var sortOrder: Int
    var relatedTopicIds: [UUID]?

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        category: HelpCategory,
        keywords: [String] = [],
        sortOrder: Int = 0,
        relatedTopicIds: [UUID]? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.keywords = keywords
        self.sortOrder = sortOrder
        self.relatedTopicIds = relatedTopicIds
    }

    // MARK: - Search Support

    /// Check if topic matches a search query
    func matches(query: String) -> Bool {
        let lowercaseQuery = query.lowercased()

        // Search in title
        if title.lowercased().contains(lowercaseQuery) {
            return true
        }

        // Search in content
        if content.lowercased().contains(lowercaseQuery) {
            return true
        }

        // Search in keywords
        for keyword in keywords {
            if keyword.lowercased().contains(lowercaseQuery) {
                return true
            }
        }

        return false
    }

    /// Calculate relevance score for search ranking
    func relevanceScore(for query: String) -> Int {
        let lowercaseQuery = query.lowercased()
        var score = 0

        // Title match is most relevant (highest score)
        if title.lowercased().contains(lowercaseQuery) {
            score += 100
            // Exact title match gets even higher score
            if title.lowercased() == lowercaseQuery {
                score += 50
            }
        }

        // Keyword matches are second most relevant
        for keyword in keywords {
            if keyword.lowercased().contains(lowercaseQuery) {
                score += 50
                // Exact keyword match gets bonus
                if keyword.lowercased() == lowercaseQuery {
                    score += 25
                }
            }
        }

        // Content match is least relevant but still counts
        if content.lowercased().contains(lowercaseQuery) {
            score += 10
        }

        return score
    }

    // Hashable conformance - hash by id only
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Equatable conformance
    static func == (lhs: HelpTopic, rhs: HelpTopic) -> Bool {
        lhs.id == rhs.id
    }
}
