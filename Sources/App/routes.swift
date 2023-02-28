import Vapor

func routes(_ app: Application) throws {
    
    // only use routes from the UserEventController
    try app.register(collection: UserEventController())
}
