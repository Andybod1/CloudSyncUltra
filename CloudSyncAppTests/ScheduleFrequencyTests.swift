//
//  ScheduleFrequencyTests.swift
//  CloudSyncAppTests
//
//  Tests for ScheduleFrequency enum
//

import XCTest
@testable import CloudSyncApp

final class ScheduleFrequencyTests: XCTestCase {

    func test_ScheduleFrequency_AllCases() {
        let allCases = ScheduleFrequency.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.hourly))
        XCTAssertTrue(allCases.contains(.daily))
        XCTAssertTrue(allCases.contains(.weekly))
        XCTAssertTrue(allCases.contains(.custom))
    }

    func test_ScheduleFrequency_RawValues() {
        XCTAssertEqual(ScheduleFrequency.hourly.rawValue, "Hourly")
        XCTAssertEqual(ScheduleFrequency.daily.rawValue, "Daily")
        XCTAssertEqual(ScheduleFrequency.weekly.rawValue, "Weekly")
        XCTAssertEqual(ScheduleFrequency.custom.rawValue, "Custom Interval")
    }

    func test_ScheduleFrequency_Icons() {
        XCTAssertEqual(ScheduleFrequency.hourly.icon, "clock")
        XCTAssertEqual(ScheduleFrequency.daily.icon, "calendar")
        XCTAssertEqual(ScheduleFrequency.weekly.icon, "calendar.badge.clock")
        XCTAssertEqual(ScheduleFrequency.custom.icon, "timer")
    }

    func test_ScheduleFrequency_Descriptions() {
        XCTAssertEqual(ScheduleFrequency.hourly.description, "Every hour")
        XCTAssertEqual(ScheduleFrequency.daily.description, "Once a day")
        XCTAssertEqual(ScheduleFrequency.weekly.description, "Once a week")
        XCTAssertEqual(ScheduleFrequency.custom.description, "Custom interval")
    }

    func test_ScheduleFrequency_Codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for frequency in ScheduleFrequency.allCases {
            let data = try encoder.encode(frequency)
            let decoded = try decoder.decode(ScheduleFrequency.self, from: data)
            XCTAssertEqual(decoded, frequency)
        }
    }
}
