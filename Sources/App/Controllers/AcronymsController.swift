import Vapor

struct AcronymsController: RouteCollection {

  func boot(router: Router) throws {
    let acronymRoute = router.grouped("api", "acronym")
    acronymRoute.get(use: getAllHandler)
    acronymRoute.post(use: create)
    acronymRoute.get(Acronym.parameter, use: getAcronym)
    acronymRoute.delete(Acronym.parameter, use: deleteAcronym)
    acronymRoute.put(Acronym.parameter, use: update)
  }

  func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
    return Acronym.query(on: req).all()
  }

  func create(_ req: Request) throws -> Future<Acronym> {
    let acronym = try req.content.decode(Acronym.self)
    return acronym.save(on: req)
  }

  func getAcronym(_ req: Request) throws -> Future<Acronym> {
    return try req.parameters.next(Acronym.self)
  }

  func deleteAcronym(_ req: Request) throws -> Future<HTTPStatus> {
    return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self, { acronym in
      return acronym.delete(on: req).transform(to: .noContent)
    })
  }

  func update(_ req: Request) throws -> Future<Acronym> {
    return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { acronym, updatedAcronym in
      acronym.short = updatedAcronym.short
      acronym.long = updatedAcronym.long
      return acronym.save(on: req)
    })
  }
}


