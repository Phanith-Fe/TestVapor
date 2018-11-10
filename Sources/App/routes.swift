import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

  let acronymRouteController = AcronymsController()
  try router.register(collection: acronymRouteController)

  let userRouteController = UserController()
  try router.register(collection: userRouteController)
}
