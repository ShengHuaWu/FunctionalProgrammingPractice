import Foundation

struct LogInParameters {
    let username: String
    let password: String
    
    func makeBase64String() -> String {
        return Data("\(username):\(password)".utf8).base64EncodedString()
    }
}
