//
//  UserController.swift
//  App
//
//  Created by Phanith Ny on 11/9/18.
//

import Vapor

struct UserController: RouteCollection {

  func boot(router: Router) throws {
    let userController = router.grouped("api", "user")
    userController.get(use: getAll)
    userController.post(use: create)
    userController.delete(User.parameter, use: delete)
    userController.put(User.parameter, use: update)
    userController.get(User.parameter, use: get)
  }

  func getAll(_ req: Request) throws -> Future<[User]> {
    return User.query(on: req).all()
  }

  func get(_ req: Request) throws -> Future<User> {
    return try req.parameters.next(User.self)
  }

  func create(_ req: Request) throws -> Future<User> {
    guard let data = req.http.body.convertToHTTPBody().data, let userData = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
      throw Abort(.badRequest)
    }
    guard let name = userData["name"] as? String else {
      throw Abort(.badRequest, reason: "Field name is required")
    }
    guard let username = userData["username"] as? String else {
      throw Abort(.badRequest, reason: "Field username is required")
    }
    return User(name: name, username: username).save(on: req)
//    return try req.content.decode(User.self).flatMap(to: User.self, { user in
//      return user.save(on: req)
//    })
  }

  func delete(_ req: Request) throws -> Future<String> {
    return try req.parameters.next(User.self).flatMap(to: String.self, { user in
      return user.delete(on: req).transform(to: "")
    })
  }

  func update(_ req: Request) throws -> Future<User> {
    return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(User.self), { user, updatedUser in
      user.name = updatedUser.name
      user.username = updatedUser.username
      return user.save(on: req)
    })
  }
}
