//
//  File.swift
//  
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent

struct CreateItemsListMigration : AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema("itemslist")
            .id()
            .field("item_name", .string, .required)
            .field("quantity", .string , .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("itemslist").delete()
    }
    
}
