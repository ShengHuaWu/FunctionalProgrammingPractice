import Foundation

extension URLSessionConfiguration {
    static var base: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        return config
    }
}
