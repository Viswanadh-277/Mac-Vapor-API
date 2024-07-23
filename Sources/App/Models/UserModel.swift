//
//  UserModel.swift
//
//
//  Created by KSMACMINI-016 on 11/07/24.
//

import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @OptionalField(key: "last_name")
    var lastName: String?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "phone_number")
    var phoneNumber: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "is_verified")
    var isVerified: Bool
    
    @Children(for: \.$userID)
    var items: [CreateListModel]
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, lastName: String? = nil, username: String, email: String, phoneNumber: String, passwordHash: String, isVerified: Bool = false) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
        self.passwordHash = passwordHash
        self.isVerified = isVerified
    }
}
