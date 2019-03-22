import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let apiGroup = router.grouped("api")
    let version1Group = apiGroup.grouped("v1")
    
    let recordsController = RecordsController()
    try version1Group.register(collection: recordsController)
}
