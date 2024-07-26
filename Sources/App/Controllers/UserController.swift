//
//  UserController.swift
//
//
//  Created by KSMACMINI-016 on 11/07/24.
//

import Fluent
import Vapor
import Mailgun
import Crypto

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("register",use: registerHandler)
        usersRoute.post("verify", use: verifyHandler)
        usersRoute.get("allusers", use: getAllUsersHandler)
        usersRoute.post("login", use: loginHandler)
        usersRoute.post("deleteUser", use: deleteUserHandler)
        usersRoute.post("editUser", use: editProfileHandler)
    }
    
    // /users/register ---> POST Request
    @Sendable
    func registerHandler(_ req: Request) async throws -> Response {
        do {
            let userRegistration = try req.content.decode(UserRegistration.self)
            
            // Validate required fields
            try validateField("First name", value: userRegistration.firstName)
            try validateField("Username", value: userRegistration.username)
            try validateField("Email", value: userRegistration.email)
            try validateField("Phone number", value: userRegistration.phoneNumber)
            try validateField("Password", value: userRegistration.password)
            try validateField("Confirm Password", value: userRegistration.confirmPassword)
            
            // Check if passwords match
            guard userRegistration.password == userRegistration.confirmPassword else {
                throw Abort(.badRequest, reason: "Passwords do not match")
            }
            
            // Check if username, email, or phone number already exist
            let existingUser = try await User.query(on: req.db)
                .group(.or) { or in
                    or.filter(\.$username == userRegistration.username)
                    or.filter(\.$email == userRegistration.email)
                    or.filter(\.$phoneNumber == userRegistration.phoneNumber)
                }
                .first()
            
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "Username, email, or phone number already exists")
            }
            
            // Hash the password
            guard let hashedPassword = try? Bcrypt.hash(userRegistration.password) else {
                throw Abort(.internalServerError, reason: "Failed to hash password")
            }
            
            // Create and save the user
            let newUser = User(
                firstName: userRegistration.firstName,
                lastName: userRegistration.lastName,
                username: userRegistration.username,
                email: userRegistration.email,
                phoneNumber: userRegistration.phoneNumber,
                passwordHash: hashedPassword
            )
            
            try await newUser.save(on: req.db)
            
            let userDetails = UserData(firstName: newUser.firstName,
                                       lastName: newUser.lastName ?? "",
                                       passwordHash: newUser.passwordHash,
                                       username: newUser.username,
                                       email: newUser.email,
                                       isVerified: newUser.isVerified,
                                       id: newUser.id ?? UUID(),
                                       phoneNumber: newUser.phoneNumber)
            
            let successResponse = UserResponse(status: 1, message: "User registered successfully for email: \(newUser.email)", data: userDetails)
            let response = Response(status: .ok)
            try response.content.encode(successResponse)
            return response
            
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    // /users/allusers ---> GET Request
    @Sendable
    func getAllUsersHandler(_ req: Request) async throws -> [User] {
        return try await User.query(on: req.db).all()
    }
    
    // /users/verify ---> POST Request
    @Sendable
    func verifyHandler(_ req: Request) async throws -> Response {
        do {
            let verifyRequest = try req.content.decode(VerifyEmailInput.self)
            
            guard let user = try await User.query(on: req.db)
                .filter(\.$email == verifyRequest.email)
                .first() else {
                throw Abort(.notFound, reason: "User not found")
            }
            
            guard !user.isVerified else {
                throw Abort(.badRequest, reason: "User is already verified")
            }
            
            user.isVerified = true
            try await user.save(on: req.db)
            
            let userDetails = UserData(firstName: user.firstName,
                                       lastName: user.lastName ?? "",
                                       passwordHash: user.passwordHash,
                                       username: user.username,
                                       email: user.email,
                                       isVerified: user.isVerified,
                                       id: user.id ?? UUID(),
                                       phoneNumber: user.phoneNumber)
            
            let successResponse = UserResponse(status: 1, message: "User verification successful for email: \(verifyRequest.email)", data: userDetails)
            let response = Response(status: .ok)
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    // /user/login ---> POST Request
    @Sendable
    func loginHandler(req: Request) async throws -> Response {
        do {
            // Decode login data from request
            let loginData = try req.content.decode(LoginInput.self)
            
            // Check if email or password is empty
            try validateField("Email", value: loginData.email)
            try validateField("Password", value: loginData.password)
            
            
            // Find user by email
            guard let user = try await User.query(on: req.db)
                .filter(\.$email == loginData.email)
                .first() else {
                // User not found
                throw Abort(.notFound, reason: "User not found")
            }
            
            // Check if user is verified
            guard user.isVerified else {
                let errorResponse = ErrorResponse(status: 2, message: "Please verify your email")
                let response = Response(status: .unauthorized)
                try response.content.encode(errorResponse)
                return response
            }
            
            // Verify the password
            guard try Bcrypt.verify(loginData.password, created: user.passwordHash) else {
                throw Abort(.unauthorized, reason: "Invalid password")
            }
            
            let userDetails = UserData(firstName: user.firstName,
                                       lastName: user.lastName ?? "",
                                       passwordHash: user.passwordHash,
                                       username: user.username,
                                       email: user.email,
                                       isVerified: user.isVerified,
                                       id: user.id ?? UUID(),
                                       phoneNumber: user.phoneNumber)
            
            // Create a response based on successful login
            let successResponse = UserResponse(status: 1, message: "Login successful", data: userDetails)
            let response = Response(status: .ok)
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    @Sendable
    func deleteUserHandler(_ req: Request) async throws -> Response {
        // Decode the userID from the request body
        let deleteRequest = try req.content.decode(DeleteUserRequest.self)
        let userID = deleteRequest.userID
        
        // Fetch the user by ID
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        // Fetch all lists associated with the user
        let lists = try await CreateListModel.query(on: req.db)
            .filter(\.$userID.$id == userID)
            .all()
        
        // For each list, delete all items associated with it
        for list in lists {
            try await ItemsListModel.query(on: req.db)
                .filter(\.$list.$id == list.id!)
                .delete()
        }
        
        // Delete all lists associated with the user
        try await CreateListModel.query(on: req.db)
            .filter(\.$userID.$id == userID)
            .delete()
        
        // Delete the user
        try await user.delete(on: req.db)
        
        let successResponse = UserResponse(status: 1, message: "User deleted successfully", data: nil)
        let response = Response(status: .ok)
        try response.content.encode(successResponse)
        return response
    }

    @Sendable
    func editProfileHandler(_ req: Request) async throws -> Response {
        let updatedUserData = try req.content.decode(EditUserInputWithID.self)
        
        guard let user = try await User.find(updatedUserData.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        // Update user details
        if let firstName = updatedUserData.firstName {
            user.firstName = firstName
        }
        
        if let lastName = updatedUserData.lastName {
            user.lastName = lastName
        }
        
        if let username = updatedUserData.username {
            // Check if the new username already exists
            let existingUsername = try await User.query(on: req.db)
                .filter(\.$username == username)
                .filter(\.$id != updatedUserData.userID) // Exclude the current user
                .first()
            
            guard existingUsername == nil else {
                throw Abort(.badRequest, reason: "Username already exists")
            }
            
            user.username = username
        }
        
        if let email = updatedUserData.email {
            // Check if the new email already exists
            let existingEmail = try await User.query(on: req.db)
                .filter(\.$email == email)
                .filter(\.$id != updatedUserData.userID) // Exclude the current user
                .first()
            
            guard existingEmail == nil else {
                throw Abort(.badRequest, reason: "Email already exists")
            }
            
            user.email = email
        }
        
        if let phoneNumber = updatedUserData.phoneNumber {
            // Check if the new phone number already exists
            let existingPhoneNumber = try await User.query(on: req.db)
                .filter(\.$phoneNumber == phoneNumber)
                .filter(\.$id != updatedUserData.userID) // Exclude the current user
                .first()
            
            guard existingPhoneNumber == nil else {
                throw Abort(.badRequest, reason: "Phone number already exists")
            }
            
            user.phoneNumber = phoneNumber
        }
        
        // Save updated user
        try await user.save(on: req.db)
        
        let userDetails = UserData(firstName: user.firstName,
                                   lastName: user.lastName ?? "",
                                   passwordHash: user.passwordHash,
                                   username: user.username,
                                   email: user.email,
                                   isVerified: user.isVerified,
                                   id: user.id ?? UUID(),
                                   phoneNumber: user.phoneNumber)
        
        let successResponse = UserResponse(status: 1, message: "Profile updated successfully", data: userDetails)
        let response = Response(status: .ok)
        try response.content.encode(successResponse)
        return response
    }

    //Validations for fields
    func validateField(_ field: String, value: String) throws {
        guard !value.isEmpty else {
            throw Abort(.badRequest, reason: "\(field) is required")
        }
    }
}
