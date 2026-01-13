//
//  FileItemTests.swift
//  CloudSyncAppTests
//
//  Unit tests for FileItem model
//

import XCTest
@testable import CloudSyncApp

final class FileItemTests: XCTestCase {
    
    // MARK: - Size Formatting Tests
    
    func testFormattedSize_Bytes() {
        let file = FileItem(
            name: "small.txt",
            path: "/small.txt",
            isDirectory: false,
            size: 500,
            modifiedDate: Date()
        )
        // ByteCountFormatter may format as "500 bytes" or "500 B" depending on locale
        XCTAssertTrue(file.formattedSize.contains("500"), "Should contain size 500")
    }
    
    func testFormattedSize_Kilobytes() {
        let file = FileItem(
            name: "medium.txt",
            path: "/medium.txt",
            isDirectory: false,
            size: 2048,
            modifiedDate: Date()
        )
        XCTAssertEqual(file.formattedSize, "2 KB")
    }
    
    func testFormattedSize_Megabytes() {
        let file = FileItem(
            name: "large.zip",
            path: "/large.zip",
            isDirectory: false,
            size: 5 * 1024 * 1024,
            modifiedDate: Date()
        )
        // ByteCountFormatter may format with locale-specific separators (e.g., "5.2 MB" or "5,2 MB")
        XCTAssertTrue(file.formattedSize.contains("5") && file.formattedSize.contains("MB"), "Should contain size 5 and MB")
    }
    
    func testFormattedSize_Gigabytes() {
        let file = FileItem(
            name: "huge.iso",
            path: "/huge.iso",
            isDirectory: false,
            size: 2 * 1024 * 1024 * 1024,
            modifiedDate: Date()
        )
        // ByteCountFormatter may format with locale-specific separators (e.g., "2.15 GB" or "2,15 GB")
        XCTAssertTrue(file.formattedSize.contains("2") && file.formattedSize.contains("GB"), "Should contain size 2 and GB")
    }
    
    func testFormattedSize_Directory() {
        let folder = FileItem(
            name: "Documents",
            path: "/Documents",
            isDirectory: true,
            size: 0,
            modifiedDate: Date()
        )
        // Implementation uses "--" for directories
        XCTAssertEqual(folder.formattedSize, "--")
    }
    
    // MARK: - Icon Tests
    
    func testIcon_Directory() {
        let folder = FileItem(
            name: "Documents",
            path: "/Documents",
            isDirectory: true
        )
        XCTAssertEqual(folder.icon, "folder.fill")
    }
    
    func testIcon_PDFFile() {
        let file = FileItem(
            name: "document.pdf",
            path: "/document.pdf",
            isDirectory: false
        )
        XCTAssertEqual(file.icon, "doc.fill")
    }
    
    func testIcon_ImageFile() {
        let extensions = ["jpg", "jpeg", "png", "gif", "webp", "heic"]
        for ext in extensions {
            let file = FileItem(
                name: "photo.\(ext)",
                path: "/photo.\(ext)",
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "photo.fill", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_VideoFile() {
        let extensions = ["mp4", "mov", "avi", "mkv"]
        for ext in extensions {
            let file = FileItem(
                name: "video.\(ext)",
                path: "/video.\(ext)",
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "film.fill", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_AudioFile() {
        let extensions = ["mp3", "wav", "aac", "flac"]
        for ext in extensions {
            let file = FileItem(
                name: "audio.\(ext)",
                path: "/audio.\(ext)",
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "music.note", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_ZipFile() {
        let extensions = ["zip", "tar", "gz", "rar", "7z"]
        for ext in extensions {
            let file = FileItem(
                name: "archive.\(ext)",
                path: "/archive.\(ext)",
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "doc.zipper", "Failed for extension: \(ext)")
        }
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormattedDate_NotEmpty() {
        let file = FileItem(
            name: "test.txt",
            path: "/test.txt",
            isDirectory: false,
            modifiedDate: Date()
        )
        XCTAssertFalse(file.formattedDate.isEmpty)
    }
    
    // MARK: - Equality Tests
    
    func testEquality_SameID() {
        let id = UUID()
        let file1 = FileItem(
            id: id,
            name: "test.txt",
            path: "/test.txt",
            isDirectory: false
        )
        let file2 = FileItem(
            id: id,
            name: "different.txt",
            path: "/different.txt",
            isDirectory: false
        )
        // FileItem uses synthesized Equatable which compares all properties, not just ID
        XCTAssertNotEqual(file1, file2)
    }
    
    func testEquality_DifferentID() {
        let file1 = FileItem(
            name: "test.txt",
            path: "/test.txt",
            isDirectory: false
        )
        let file2 = FileItem(
            name: "test.txt",
            path: "/test.txt",
            isDirectory: false
        )
        XCTAssertNotEqual(file1, file2)
    }
    
    // MARK: - Hashable Tests
    
    func testHashable() {
        let file1 = FileItem(name: "test1.txt", path: "/test1.txt", isDirectory: false)
        let file2 = FileItem(name: "test2.txt", path: "/test2.txt", isDirectory: false)
        
        var set = Set<FileItem>()
        set.insert(file1)
        set.insert(file2)
        
        XCTAssertEqual(set.count, 2)
    }
}
