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
        try app.syncShutdownGracefully() // This is necessary to resolve the too many thread usages
    }
    
    func sendRequest<Body>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: Body?) throws -> Response where Body: Content {
        let httpRequest = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: httpRequest, using: self)
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        let responder = try make(Responder.self)
        
        return try responder.respond(to: wrappedRequest).wait()
    }
}

struct EmptyBody: Content {} // In order to satisiy the generic constraint
