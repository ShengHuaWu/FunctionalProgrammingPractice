import Foundation

extension URLSessionConfiguration {
    static var json: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        return config
    }
}
