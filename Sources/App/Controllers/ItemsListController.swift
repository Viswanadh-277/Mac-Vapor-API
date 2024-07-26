//
//  File.swift
//  
//
//  Created by KSMACMINI-016 on 13/07/24.
//

import Fluent
import Vapor

struct ItemsListController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let createdItemsList = routes.grouped("itemslist")
        createdItemsList.post("itemslistcreate", use: createItemsList(_:))
        createdItemsList.patch("itemslistupdate", use: updateItemsList(_:))
        createdItemsList.delete("itemslistdelete", use: deleteItemsList(_:))
        createdItemsList.get("getallitemslist", use: getAllItemsList(_:))
        createdItemsList.post("getitemsforlistId", use: getItemsForListId(_:))
//        createdItemsList.get("getitemsforlist/:listID", use: getItemsForList(_:))
    }
     
    // createlist/itemslistcreate --> POST Request
    @Sendable
    func createItemsList(_ req : Request) async throws -> Response {
        do {
            let createItemslist = try req.content.decode(ItemsListDTO.self)
            
            try validateField("Item Name", value: createItemslist.itemName)
            try validateField("Quantity", value: createItemslist.quantity)
            try validateField("ListId", value: "\(createItemslist.listID)")
            
            let itemList = ItemsListModel(itemName: createItemslist.itemName, quantity: createItemslist.quantity, listID: createItemslist.listID)
            
            try await itemList.save(on: req.db)
            
            let successResponse = SuccessResponse(status: 1, message: "\(itemList.itemName) Item List Created Successfully")
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
    
    // createlist/itemslistupdate --> PATCH Requestui
    @Sendable
    func updateItemsList(_ req : Request) async throws -> Response {
        do {
            let editedItemName = try req.content.decode(ItemsListUpdate.self)
            
            try validateField("Item Name", value: editedItemName.itemName)
            
            guard let itemName = try await ItemsListModel.find(editedItemName.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            itemName.itemName = editedItemName.itemName
            itemName.quantity = editedItemName.quantity
            
            try await itemName.update(on: req.db)
            
            let successResponse = SuccessResponse(status: 1, message: "Item List Updated Successfully with name : \(editedItemName.itemName)")
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
    
    // createlist/itemslistdelete --> DELETE Request
    @Sendable
    func deleteItemsList(_ req: Request) async throws -> Response {
        do {
            let deleteItemList = try req.content.decode(DeleteItemsList.self)
            
            guard let listName = try await ItemsListModel.find(deleteItemList.id, on: req.db) else {
                throw Abort(.notFound)
            }
            
            try await listName.delete(on: req.db)
            
            let successResponse = SuccessResponse(status: 1, message: "Item List Deleted Successfully")
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
    
    // /users/getallitemslist ---> GET Request
    @Sendable
    func getAllItemsList(_ req: Request) async throws -> Response {
        do {
            let fulldata = try await ItemsListModel.query(on: req.db).all()
            let dtoData = fulldata.map { $0.itemsToDTO() }
            let successResponse = ItemsListResponse(status: 1, message: "Items List Retrieved Successfully", data: dtoData)
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
    
    // /users/getitemsforlistId --> POST Request
    @Sendable
    func getItemsForListId(_ req: Request) async throws -> Response {
        do {
            let listRequest = try req.content.decode(ListRequest.self)
            let listID = listRequest.listId
            
            let items = try await ItemsListModel.query(on: req.db)
                .filter(\.$list.$id == listID)
                .all()
            let dtoData = items.map { $0.itemsToDTO() }
            let successResponse = ItemsListResponse(status: 1, message: "Items for List Retrieved Successfully", data: dtoData)
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
