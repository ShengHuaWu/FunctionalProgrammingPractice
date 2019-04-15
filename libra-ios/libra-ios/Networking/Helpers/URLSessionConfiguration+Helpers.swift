import Foundation

extension URLSessionConfiguration {
    static var base: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        if var headers = config.httpAdditionalHeaders {
            headers["Content-Type"] = "application/json"
            config.httpAdditionalHeaders = headers
        } else {
            config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        }
        
        return config
    }
}
