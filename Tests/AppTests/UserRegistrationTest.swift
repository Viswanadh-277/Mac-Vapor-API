//
//  UserRegistrationTest.swift
//  
//
//  Created by KSMACMINI-016 on 23/07/24.
//

@testable import App
import XCTVapor
import Fluent

final class UserRegistrationTest: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        self.app = try await Application.make(.testing)
        try await configure(app)
        try await app.autoMigrate()
    }
    
    override func tearDown() async throws {
//        try await app.autoRevert()
        try await self.app.asyncShutdown()
        self.app = nil
    }

    func testRegisterHandlerAPI() async throws {
        let userRegistration = UserRegistration(
            firstName: "John",
            lastName: "Doe",
            username: "johndoe",
            email: "john@example.com",
            phoneNumber: "1234567890",
            password: "password123",
            confirmPassword: "password123"
        )
        
        
        try await app.test(.POST, "/users/register", beforeRequest: { request in
            try request.content.encode(userRegistration)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(UserResponse.self))
        })
    }
    
    func testGetAllUsersHandler() async throws {
        try await app.test(.GET, "/users/allusers") { response async in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode([User].self))
        }
    }
    
    func testVerifyHandler() async throws {
        let verifyRequest = VerifyEmailInput(email: "john@example.com")
        
        try await app.test(.POST, "/users/verify", beforeRequest: { request in
            try request.content.encode(verifyRequest)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(UserResponse.self))
        })
    }
    
    func testLoginHandler() async throws {
        let loginInput = LoginInput(email: "john@example.com", password: "password123")
        
        try await app.test(.POST, "/users/login", beforeRequest: { request in
            try request.content.encode(loginInput)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(UserResponse.self))
        })
    }
    
    func testDeleteUserHandler() async throws {
        let deleteRequest = DeleteUserRequest(userID: UUID(uuidString: "ee42e5d1-29e9-4cf1-b201-ea82cd4d263d")!)
        
        try await app.test(.POST, "/users/deleteUser", beforeRequest: { request in
            try request.content.encode(deleteRequest)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(UserResponse.self))
        })
    }

    func testEditProfileHandler() async throws {
        let editUserInput = EditUserInputWithID(userID: UUID(uuidString: "ee42e5d1-29e9-4cf1-b201-ea82cd4d263d")!, firstName: "Jane", lastName: "Doe",username: "johndoe",email: "john@example.com",phoneNumber: "9876543210")
        
        try await app.test(.POST, "/users/editUser", beforeRequest: { request in
            try request.content.encode(editUserInput)
        }, afterResponse: { response async throws in
            XCTAssertEqual(response.status, .ok)
            XCTAssertNoThrow(try response.content.decode(UserResponse.self))
        })
    }
    
}
