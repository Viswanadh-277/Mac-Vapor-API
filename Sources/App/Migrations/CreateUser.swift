//
//  CreateUser.swift
//
//
//  Created by KSMACMINI-016 on 11/07/24.
//

import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string)
            .field("username", .string, .required)
            .field("email", .string, .required)
            .field("phone_number", .string, .required)
            .field("password_hash", .string, .required)
            .field("is_verified", .bool, .required)
            .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
        try await database.schema("users").delete()
    }

}
