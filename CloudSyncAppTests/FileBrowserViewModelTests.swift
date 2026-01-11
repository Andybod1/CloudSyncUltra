//
//  FileBrowserViewModelTests.swift
//  CloudSyncAppTests
//
//  Unit tests for FileBrowserViewModel
//

import XCTest
@testable import CloudSyncApp

@MainActor
final class FileBrowserViewModelTests: XCTestCase {
    
    var viewModel: FileBrowserViewModel!
    
    override func setUp() async throws {
        viewModel = FileBrowserViewModel()
    }
    
    override func tearDown() async throws {
        viewModel = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.files.isEmpty)
        XCTAssertTrue(viewModel.selectedFiles.isEmpty)
        XCTAssertEqual(viewModel.currentPath, "")
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.viewMode, .list)
        XCTAssertEqual(viewModel.sortOrder, .name)
    }
    
    // MARK: - Sorting Tests
    
    func testSortFiles_ByName() {
        viewModel.files = [
            FileItem(name: "Charlie.txt", path: "/Charlie.txt", isDirectory: false),
            FileItem(name: "Alpha.txt", path: "/Alpha.txt", isDirectory: false),
            FileItem(name: "Beta.txt", path: "/Beta.txt", isDirectory: false)
        ]
        
        viewModel.sortOrder = .name
        viewModel.sortFiles()
        
        XCTAssertEqual(viewModel.files[0].name, "Alpha.txt")
        XCTAssertEqual(viewModel.files[1].name, "Beta.txt")
        XCTAssertEqual(viewModel.files[2].name, "Charlie.txt")
    }
    
    func testSortFiles_BySize() {
        viewModel.files = [
            FileItem(name: "Small.txt", path: "/Small.txt", isDirectory: false, size: 100),
            FileItem(name: "Large.txt", path: "/Large.txt", isDirectory: false, size: 1000),
            FileItem(name: "Medium.txt", path: "/Medium.txt", isDirectory: false, size: 500)
        ]
        
        viewModel.sortOrder = .size
        viewModel.sortFiles()
        
        XCTAssertEqual(viewModel.files[0].name, "Large.txt")
        XCTAssertEqual(viewModel.files[1].name, "Medium.txt")
        XCTAssertEqual(viewModel.files[2].name, "Small.txt")
    }
    
    func testSortFiles_ByDate() {
        let now = Date()
        viewModel.files = [
            FileItem(name: "Old.txt", path: "/Old.txt", isDirectory: false, modifiedDate: now.addingTimeInterval(-3600)),
            FileItem(name: "New.txt", path: "/New.txt", isDirectory: false, modifiedDate: now),
            FileItem(name: "Middle.txt", path: "/Middle.txt", isDirectory: false, modifiedDate: now.addingTimeInterval(-1800))
        ]
        
        viewModel.sortOrder = .date
        viewModel.sortFiles()
        
        XCTAssertEqual(viewModel.files[0].name, "New.txt")
        XCTAssertEqual(viewModel.files[1].name, "Middle.txt")
        XCTAssertEqual(viewModel.files[2].name, "Old.txt")
    }
    
    func testSortFiles_DirectoriesFirst() {
        viewModel.files = [
            FileItem(name: "file.txt", path: "/file.txt", isDirectory: false),
            FileItem(name: "folder", path: "/folder", isDirectory: true),
            FileItem(name: "another.txt", path: "/another.txt", isDirectory: false)
        ]
        
        viewModel.sortOrder = .name
        viewModel.sortFiles()
        
        // Directories should come first
        XCTAssertTrue(viewModel.files[0].isDirectory)
        XCTAssertEqual(viewModel.files[0].name, "folder")
    }
    
    // MARK: - Search/Filter Tests
    
    func testFilteredFiles_NoQuery() {
        viewModel.files = [
            FileItem(name: "test.txt", path: "/test.txt", isDirectory: false),
            FileItem(name: "document.pdf", path: "/document.pdf", isDirectory: false)
        ]
        viewModel.searchQuery = ""
        
        XCTAssertEqual(viewModel.filteredFiles.count, 2)
    }
    
    func testFilteredFiles_WithQuery() {
        viewModel.files = [
            FileItem(name: "test.txt", path: "/test.txt", isDirectory: false),
            FileItem(name: "document.pdf", path: "/document.pdf", isDirectory: false),
            FileItem(name: "testfile.doc", path: "/testfile.doc", isDirectory: false)
        ]
        viewModel.searchQuery = "test"
        
        let filtered = viewModel.filteredFiles
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.allSatisfy { $0.name.lowercased().contains("test") })
    }
    
    func testFilteredFiles_CaseInsensitive() {
        viewModel.files = [
            FileItem(name: "TEST.txt", path: "/TEST.txt", isDirectory: false),
            FileItem(name: "other.pdf", path: "/other.pdf", isDirectory: false)
        ]
        viewModel.searchQuery = "test"
        
        XCTAssertEqual(viewModel.filteredFiles.count, 1)
        XCTAssertEqual(viewModel.filteredFiles[0].name, "TEST.txt")
    }
    
    // MARK: - Selection Tests
    
    func testToggleSelection_Select() {
        let file = FileItem(name: "test.txt", path: "/test.txt", isDirectory: false)
        viewModel.files = [file]
        
        viewModel.toggleSelection(file)
        
        XCTAssertTrue(viewModel.selectedFiles.contains(file.id))
    }
    
    func testToggleSelection_Deselect() {
        let file = FileItem(name: "test.txt", path: "/test.txt", isDirectory: false)
        viewModel.files = [file]
        viewModel.selectedFiles = [file.id]
        
        viewModel.toggleSelection(file)
        
        XCTAssertFalse(viewModel.selectedFiles.contains(file.id))
    }
    
    func testDeselectAll() {
        let file1 = FileItem(name: "test1.txt", path: "/test1.txt", isDirectory: false)
        let file2 = FileItem(name: "test2.txt", path: "/test2.txt", isDirectory: false)
        viewModel.files = [file1, file2]
        viewModel.selectedFiles = [file1.id, file2.id]
        
        viewModel.deselectAll()
        
        XCTAssertTrue(viewModel.selectedFiles.isEmpty)
    }
    
    // MARK: - Navigation Tests
    
    func testNavigateToFile_Directory() {
        let folder = FileItem(name: "Documents", path: "/Documents", isDirectory: true)
        viewModel.files = [folder]
        viewModel.currentPath = ""
        
        viewModel.navigateToFile(folder)
        
        XCTAssertEqual(viewModel.currentPath, "/Documents")
    }
    
    func testNavigateUp_FromSubfolder() {
        viewModel.currentPath = "/Users/test/Documents"
        
        viewModel.navigateUp()
        
        XCTAssertEqual(viewModel.currentPath, "/Users/test")
    }
    
    func testNavigateUp_FromRoot() {
        viewModel.currentPath = ""
        
        viewModel.navigateUp()
        
        XCTAssertEqual(viewModel.currentPath, "")
    }
    
    // MARK: - Path Components Tests
    
    func testPathComponents_Root() {
        viewModel.currentPath = ""
        
        let components = viewModel.pathComponents
        
        XCTAssertGreaterThanOrEqual(components.count, 1)
    }
    
    // MARK: - View Mode Tests
    
    func testViewMode_Toggle() {
        XCTAssertEqual(viewModel.viewMode, .list)
        
        viewModel.viewMode = .grid
        XCTAssertEqual(viewModel.viewMode, .grid)
        
        viewModel.viewMode = .list
        XCTAssertEqual(viewModel.viewMode, .list)
    }
}
