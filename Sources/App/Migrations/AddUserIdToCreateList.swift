//
//  AddUserIdToCreateList.swift
//  
//
//  Created by KSMACMINI-016 on 18/07/24.
//

import Fluent

struct AddUserIdToCreateList : AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("createlist")
            .field("user_id", .uuid, .references(User.schema, "id"))
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("createlist")
            .deleteField("user_id")
            .update()
    }
    
}
