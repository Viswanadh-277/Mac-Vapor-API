//
//  File.swift
//  
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent
import Vapor

struct ItemsListDTO : Content {
    let id : UUID?
    let itemName : String
    let quantity : String
    var listID: UUID
}

struct ItemsListUpdate : Content {
    let id : UUID?
    let itemName : String
    let quantity : String
}

struct ItemsListResponse: Content {
    let status: Int
    let message: String
    let data : [ItemsListDTO]
}

struct DeleteItemsList : Content {
    let id : UUID
}

struct ListRequest: Content {
    let listId: UUID
}

//this is for test cases
struct ItemsList : Content {
    let itemName : String
    let quantity : String
    var listID: UUID
}
