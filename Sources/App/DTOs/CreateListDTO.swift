//
//  File.swift
//  
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent
import Vapor

struct CreateListDTO : Content {
    let id : UUID?
    let listName : String
    let userID : UUID
}

struct CreateListUpdate : Content {
    let id : UUID?
    let listName : String
}

struct CreateListResponse: Content {
    let status: Int
    let message: String
    let data : [CreateListDTO]
}

struct DeleteList : Content {
    let id : UUID
}

struct UserIdRequest: Content {
    let userId: UUID
}

//this is for test cases
struct CreateList : Content {
    let listName : String
    let userID : UUID
}

