//
//  CreateListModel.swift
//
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent
import Vapor

final class CreateListModel : Model, Content, @unchecked Sendable {
    static let schema = "createlist"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "list_name")
    var listName : String
    
    @Parent(key: "user_id")
    var userID: User
    
    @Children(for: \.$list)
    var items: [ItemsListModel]
    
    init() {}
    
    init(id: UUID? = nil, listName: String, userID : UUID) {
        self.id = id
        self.listName = listName
        self.$userID.id = userID
    }
    
    func toDTO() -> CreateListDTO {
        return CreateListDTO(id: self.id, listName: self.listName, userID: self.$userID.id)
    }
    
}
