import Foundation

struct Storage {
    let saveToken = { try save($0, as: .token) }
    let fetchToken = { try fetchEntity(as: .token) }
    let deleteToken = { try deleteEntity(as: .token) }
}
