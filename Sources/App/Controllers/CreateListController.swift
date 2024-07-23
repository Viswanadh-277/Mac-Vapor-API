//
//  CreateListController.swift
//
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent
import Vapor

struct CreateListController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let createdList = routes.grouped("createlist")
        createdList.post("listcreate", use: createList(_:))
        createdList.patch("listupdate", use: updateList(_:))
        createdList.delete("listdelete", use: deleteList(_:))
        createdList.get("getalllist", use: getAllList(_:))
        createdList.post("getlistbyuserid", use: getListByUserId(_:))
    }
     
    // createlist/listcreate --> POST Request
    @Sendable
    func createList(_ req : Request) async throws -> Response {
        do {
            let createlist = try req.content.decode(CreateListDTO.self)
            
            try validateField("List Name", value: createlist.listName)
            
            let list = CreateListModel(listName: createlist.listName, userID: createlist.userID)
            
            try await list.save(on: req.db)
            
            let successResponse = SuccessResponse(status: 1, message: "\(list.listName) List Created Successfully")
            let response = Response(status: .ok)
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        } catch {
            let errorResponse = ErrorResponse(status: 0, message: "Unexpected error")
            let response = Response(status: .internalServerError)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    // createlist/listupdate --> PATCH Request
    @Sendable
    func updateList(_ req : Request) async throws -> Response {
        do {
            let editedListName = try req.content.decode(CreateListUpdate.self)
            
            try validateField("List Name", value: editedListName.listName)
            
            guard let listName = try await CreateListModel.find(editedListName.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            listName.listName = editedListName.listName
            
            try await listName.update(on: req.db)
            
            let successResponse = SuccessResponse(status: 1, message: "List Updated Successfully with name : \(editedListName.listName)")
            let response = Response(status: .ok)
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        } catch {
            let errorResponse = ErrorResponse(status: 0, message: "Unexpected error")
            let response = Response(status: .internalServerError)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    // createlist/listdelete --> DELETE Request
    @Sendable
    func deleteList(_ req: Request) async throws -> Response {
        do {
            let deleteList = try req.content.decode(DeleteList.self)
            
            guard let listName = try await CreateListModel.find(deleteList.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            try await listName.delete(on: req.db)
            
            let successResponse = SuccessResponse(status: 1, message: "List Deleted Successfully")
            let response = Response(status: .ok)
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        } catch {
            let errorResponse = ErrorResponse(status: 0, message: "Unexpected error")
            let response = Response(status: .internalServerError)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    // /createlist/getalllist ---> GET Request
    @Sendable
    func getAllList(_ req: Request) async throws -> Response {
        do {
            let fulldata = try await CreateListModel.query(on: req.db).all()
            let dtoData = fulldata.map { $0.toDTO() }
            let successResponse = CreateListResponse(status: 1, message: "List Retrieved Successfully", data: dtoData)
            let response = Response()
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        } catch {
            let errorResponse = ErrorResponse(status: 0, message: "Unexpected error")
            let response = Response(status: .internalServerError)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    // /createlist/getlistbyuserid ---> POST Request
    @Sendable
    func getListByUserId(_ req: Request) async throws -> Response {
        do {
            let UserIdRequest = try req.content.decode(UserIdRequest.self)
            let userID = UserIdRequest.userId
            
            let items = try await CreateListModel.query(on: req.db)
                .filter(\.$userID.$id == userID)
                .all()
            let dtoData = items.map { $0.toDTO() }
            let successResponse = CreateListResponse(status: 1, message: "List Retrieved Successfully", data: dtoData)
            let response = Response()
            try response.content.encode(successResponse)
            return response
        } catch let abortError as AbortError {
            let errorResponse = ErrorResponse(status: 0, message: abortError.reason)
            let response = Response(status: abortError.status)
            try response.content.encode(errorResponse)
            return response
        } catch {
            let errorResponse = ErrorResponse(status: 0, message: "Unexpected error")
            let response = Response(status: .internalServerError)
            try response.content.encode(errorResponse)
            return response
        }
    }
    
    //Validations for fields
    func validateField(_ field: String, value: String) throws {
        guard !value.isEmpty else {
            throw Abort(.badRequest, reason: "\(field) is required")
        }
    }
}
