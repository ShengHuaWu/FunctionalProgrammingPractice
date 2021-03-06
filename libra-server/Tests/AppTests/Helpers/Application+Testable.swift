@testable import App
import Vapor
import FluentPostgreSQL

extension Application {
    static func testable(envArgs: [String]? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        
        if let environmentArgs = envArgs {
            env.arguments = environmentArgs
        }
        
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        
        return app        
    }
    
    static func reset() throws {
        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
        
        // Create an app object to run the revert command
        let app = try Application.testable(envArgs: revertEnvironmentArgs)
        try app.asyncRun().wait()
        // try app.syncShutdownGracefully() // TODO: This could solve too many thread usages but the test will get stuck :(
    }
    
    func sendRequest<Body>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: Body?, bodyEncoder: JSONEncoder = .init()) throws -> Response where Body: Content {
        let httpRequest = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: httpRequest, using: self)
        if let body = body {
            try wrappedRequest.content.encode(json: body, using: bodyEncoder)
        }
        let responder = try make(Responder.self)
        
        return try responder.respond(to: wrappedRequest).wait()
    }
}

struct EmptyBody: Content {} // In order to satisiy the generic constraint
