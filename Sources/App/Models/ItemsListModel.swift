//
//  File.swift
//  
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent
import Vapor

final class ItemsListModel : Model, Content, @unchecked Sendable {
    static let schema = "itemslist"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "item_name")
    var itemName : String
    
    @Field(key: "quantity")
    var quantity : String
    
    @Parent(key: "list_id")
    var list: CreateListModel
    
    init() {}
    
    init(id: UUID? = nil, itemName: String, quantity: String, listID: UUID) {
        self.id = id
        self.itemName = itemName
        self.quantity = quantity
        self.$list.id = listID
    }
    
    func itemsToDTO() -> ItemsListDTO {
        return ItemsListDTO(id: self.id, itemName: self.itemName, quantity: self.quantity,listID: self.$list.id)
    }
    
}
