//
//  ItemsListTest.swift
//  
//
//  Created by KSMACMINI-016 on 25/07/24.
//

@testable import App
import XCTVapor
import Fluent

final class ItemsListTest: XCTestCase {
    
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
    
    func testCreateItemsListSuccess() async throws {
        let createItem = ItemsList(itemName: "Milk", quantity: "2", listID: UUID(uuidString: "E81FCC52-13B1-48B6-B959-42CBDFAEC45F") ?? UUID())
        
        try await app.test(.POST, "/itemslist/itemslistcreate", beforeRequest: { req in
            try req.content.encode(createItem)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(SuccessResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.message, "Milk Item List Created Successfully")
        })
    }
    
    func testUpdateList() async throws {
        let updateItem = ItemsListUpdate(id: UUID(uuidString: "e733eb02-a378-46a8-b57f-9c98a3b15fe5") ?? UUID(), itemName: "Bread", quantity: "3")
        
        try await app.test(.PATCH, "/itemslist/itemslistupdate", beforeRequest: { req in
            try req.content.encode(updateItem)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(SuccessResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.message, "Item List Updated Successfully with name : Bread")
        })
    }
    
    func testDeleteItemsListSuccess() async throws {
        let deleteItem = DeleteItemsList(id: UUID(uuidString: "e733eb02-a378-46a8-b57f-9c98a3b15fe5") ?? UUID())
        
        try await app.test(.DELETE, "/itemslist/itemslistdelete", beforeRequest: { req in
            try req.content.encode(deleteItem)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(SuccessResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.message, "Item List Deleted Successfully")
        })
    }
    
    func testGetAllItemsListSuccess() async throws {
        try await app.test(.GET, "/itemslist/getallitemslist", afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(ItemsListResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.message, "Items List Retrieved Successfully")
        })
    }
    
    func testGetItemsForListIdSuccess() async throws {
        let listRequest = ListRequest(listId: UUID(uuidString: "E81FCC52-13B1-48B6-B959-42CBDFAEC45F") ?? UUID())
        
        try await app.test(.POST, "/itemslist/getitemsforlistId", beforeRequest: { req in
            try req.content.encode(listRequest)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .ok)
            let successResponse = try res.content.decode(ItemsListResponse.self)
            XCTAssertEqual(successResponse.status, 1)
            XCTAssertEqual(successResponse.message, "Items for List Retrieved Successfully")
        })
    }
    
}
