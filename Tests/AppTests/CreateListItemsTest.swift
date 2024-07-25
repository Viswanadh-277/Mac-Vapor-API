//
//  CreateListItemsTest.swift
//  
//
//  Created by KSMACMINI-016 on 25/07/24.
//

@testable import App
import XCTVapor
import Fluent

final class CreateListItemsTest: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws {
        try await self.app.asyncShutdown()
        self.app = nil
    }
    
    func testCreateList() async throws {
        let listData = CreateList(listName: "Test List", userID: UUID(uuidString: "3788afa4-624e-4238-9258-3d53373d7ba0") ?? UUID())
        
        try await app.test(.POST, "/createlist/listcreate", beforeRequest: { request in
            try request.content.encode(listData)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(SuccessResponse.self))
        })
    }
    
    func testUpdateList() async throws {
        // First, create a list to update
        let listData = CreateList(listName: "New List", userID: UUID(uuidString: "3788afa4-624e-4238-9258-3d53373d7ba0") ?? UUID())
        var createdList: CreateListModel!
        
        try await app.test(.POST, "/createlist/listcreate", beforeRequest: { req in
            try req.content.encode(listData)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            createdList = try await CreateListModel.query(on: app.db).filter(\.$listName == "New List").first().get()
        })
        
        // Now update the list
        let updateData = CreateListUpdate(id: createdList.id!, listName: "Updated List")
        
        try await app.test(.PATCH, "/createlist/listupdate", beforeRequest: { request in
            try request.content.encode(updateData)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(SuccessResponse.self))
        })
    }
    
    func testDeleteList() async throws {
        // First, create a list to delete
        let listData = CreateList(listName: "Good List", userID: UUID(uuidString: "3788afa4-624e-4238-9258-3d53373d7ba0") ?? UUID())
        var createdList: CreateListModel!
        
        try await app.test(.POST, "/createlist/listcreate", beforeRequest: { req in
            try req.content.encode(listData)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            createdList = try await CreateListModel.query(on: app.db).filter(\.$listName == "Good List").first().get()
        })
        
        // Now delete the list
        let deleteData = DeleteList(id: createdList.id!)
        
        try await app.test(.DELETE, "/createlist/listdelete", beforeRequest: { req in
            try req.content.encode(deleteData)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(SuccessResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.message, "List Deleted Successfully")
        })
    }
    
    func testGetAllList() async throws {
        // Retrieve all lists
        try await app.test(.GET, "/createlist/getalllist", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(CreateListResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.data.count, 4)
        })
    }
    
    func testGetListByUserId() async throws {
        let userIdRequest = UserIdRequest(userId: UUID(uuidString: "3788afa4-624e-4238-9258-3d53373d7ba0") ?? UUID())
        
        try await app.test(.POST, "/createlist/getlistbyuserid", beforeRequest: { req in
            try req.content.encode(userIdRequest)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(CreateListResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.data.count, 4)
        })
    }
    
}
