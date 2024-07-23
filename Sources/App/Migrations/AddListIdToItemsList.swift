//
//  AddListIdToItemsList.swift
//
//
//  Created by KSMACMINI-016 on 18/07/24.
//

import Fluent

struct AddListIdToItemsList : AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("itemslist")
            .field("list_id", .uuid, .references("createlist", "id"))
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("itemslist")
            .deleteField("list_id")
            .update()
    }
    
}
