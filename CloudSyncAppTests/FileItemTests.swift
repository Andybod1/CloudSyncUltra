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
            size: 500,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.formattedSize, "500 B")
    }
    
    func testFormattedSize_Kilobytes() {
        let file = FileItem(
            name: "medium.txt",
            path: "/medium.txt",
            size: 2048,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.formattedSize, "2 KB")
    }
    
    func testFormattedSize_Megabytes() {
        let file = FileItem(
            name: "large.zip",
            path: "/large.zip",
            size: 5 * 1024 * 1024,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.formattedSize, "5 MB")
    }
    
    func testFormattedSize_Gigabytes() {
        let file = FileItem(
            name: "huge.iso",
            path: "/huge.iso",
            size: 2 * 1024 * 1024 * 1024,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.formattedSize, "2 GB")
    }
    
    func testFormattedSize_Directory() {
        let folder = FileItem(
            name: "Documents",
            path: "/Documents",
            size: 0,
            modifiedDate: Date(),
            isDirectory: true
        )
        XCTAssertEqual(folder.formattedSize, "-")
    }
    
    func testFormattedSize_NegativeSize() {
        let file = FileItem(
            name: "test.txt",
            path: "/test.txt",
            size: -1,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.formattedSize, "-1 byte")
    }
    
    // MARK: - Icon Tests
    
    func testIcon_Directory() {
        let folder = FileItem(
            name: "Documents",
            path: "/Documents",
            size: 0,
            modifiedDate: Date(),
            isDirectory: true
        )
        XCTAssertEqual(folder.icon, "folder.fill")
    }
    
    func testIcon_TextFile() {
        let file = FileItem(
            name: "readme.txt",
            path: "/readme.txt",
            size: 100,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.icon, "doc.text")
    }
    
    func testIcon_ImageFile() {
        let extensions = ["jpg", "jpeg", "png", "gif", "webp", "heic"]
        for ext in extensions {
            let file = FileItem(
                name: "photo.\(ext)",
                path: "/photo.\(ext)",
                size: 1000,
                modifiedDate: Date(),
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "photo", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_VideoFile() {
        let extensions = ["mp4", "mov", "avi", "mkv"]
        for ext in extensions {
            let file = FileItem(
                name: "video.\(ext)",
                path: "/video.\(ext)",
                size: 1000,
                modifiedDate: Date(),
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "film", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_AudioFile() {
        let extensions = ["mp3", "wav", "aac", "flac", "m4a"]
        for ext in extensions {
            let file = FileItem(
                name: "audio.\(ext)",
                path: "/audio.\(ext)",
                size: 1000,
                modifiedDate: Date(),
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "music.note", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_PDFFile() {
        let file = FileItem(
            name: "document.pdf",
            path: "/document.pdf",
            size: 1000,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.icon, "doc.richtext")
    }
    
    func testIcon_ZipFile() {
        let extensions = ["zip", "tar", "gz", "rar", "7z"]
        for ext in extensions {
            let file = FileItem(
                name: "archive.\(ext)",
                path: "/archive.\(ext)",
                size: 1000,
                modifiedDate: Date(),
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "doc.zipper", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_CodeFile() {
        let extensions = ["swift", "py", "js", "ts", "java", "c", "cpp", "h", "html", "css"]
        for ext in extensions {
            let file = FileItem(
                name: "code.\(ext)",
                path: "/code.\(ext)",
                size: 1000,
                modifiedDate: Date(),
                isDirectory: false
            )
            XCTAssertEqual(file.icon, "chevron.left.forwardslash.chevron.right", "Failed for extension: \(ext)")
        }
    }
    
    func testIcon_UnknownFile() {
        let file = FileItem(
            name: "unknown.xyz",
            path: "/unknown.xyz",
            size: 1000,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file.icon, "doc")
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormattedDate_Today() {
        let file = FileItem(
            name: "test.txt",
            path: "/test.txt",
            size: 100,
            modifiedDate: Date(),
            isDirectory: false
        )
        // Should contain today's date
        XCTAssertFalse(file.formattedDate.isEmpty)
    }
    
    // MARK: - Equality Tests
    
    func testEquality_SameID() {
        let id = UUID()
        let file1 = FileItem(
            id: id,
            name: "test.txt",
            path: "/test.txt",
            size: 100,
            modifiedDate: Date(),
            isDirectory: false
        )
        let file2 = FileItem(
            id: id,
            name: "different.txt",
            path: "/different.txt",
            size: 200,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertEqual(file1, file2)
    }
    
    func testEquality_DifferentID() {
        let file1 = FileItem(
            name: "test.txt",
            path: "/test.txt",
            size: 100,
            modifiedDate: Date(),
            isDirectory: false
        )
        let file2 = FileItem(
            name: "test.txt",
            path: "/test.txt",
            size: 100,
            modifiedDate: Date(),
            isDirectory: false
        )
        XCTAssertNotEqual(file1, file2)
    }
}
