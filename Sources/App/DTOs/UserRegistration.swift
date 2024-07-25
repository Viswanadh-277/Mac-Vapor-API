//
//  UserRegistration.swift
//
//
//  Created by KSMACMINI-016 on 11/07/24.
//

import Fluent
import Vapor

struct UserRegistration: Content {
    var firstName: String
    var lastName: String?
    var username: String
    var email: String
    var phoneNumber: String
    var password: String
    var confirmPassword: String
}

struct VerifyEmailInput: Content {
    let email: String
}

struct LoginInput: Content {
    var email: String
    var password: String
}

struct EditUserInputWithID: Content {
    var userID: UUID
    var firstName: String?
    var lastName: String?
    var username: String?
    var email: String?
    var phoneNumber: String?
}

struct DeleteUserRequest: Content {
    var userID: UUID
}

struct SuccessResponse: Content {
    let status: Int
    let message: String
}

struct UserResponse: Content {
    let status: Int
    let message: String
    var data: UserData?
}

struct UserData: Content {
    var firstName : String
    var lastName : String
    var passwordHash : String
    var username: String
    var email: String
    var isVerified: Bool
    var id: UUID
    var phoneNumber: String
}

struct ErrorResponse: Content {
    let status: Int
    let message: String
}
