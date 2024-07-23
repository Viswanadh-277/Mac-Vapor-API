//
//  CreateListMigration.swift
//  
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent

struct CreateListMigration : AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("createlist")
            .id()
            .field("list_name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("createlist").delete()
    }
    
}
