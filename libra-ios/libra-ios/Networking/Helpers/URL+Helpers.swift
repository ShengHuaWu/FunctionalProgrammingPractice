import Foundation

extension URL {
    static var base: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "Base URL") as? String,
            let url = URL(string: urlString) else {
                preconditionFailure("Unable to load base url from info.plist")
        }
        
        return url
    }
    
    func appendingPathComponent(for endpoint: Endpoint) -> URL {
        return appendingPathComponent(endpoint.path)
    }
}
