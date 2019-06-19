import Foundation
import Vapor

struct ResourcePersisting {
    let save = { try saveData($0, to: makeResourcesURL(with: $1)) }
    let delete = makeResourcesURL(with:) >>> deleteData(at:)
    let fetch = makeResourcesURL(with:) >>> fetchData(from:)
}

// MARK: - Private
private func makeResourcesURL(with name: String) throws -> URL {
    let directory = DirectoryConfig.detect()
    let workPath = directory.workDir
    let directoryURL = URL(fileURLWithPath: workPath).appendingPathComponent("Resources/Records", isDirectory: true)
    
    let fileManager = Current.fileManager()
    if !fileManager.fileExists(atPath: directoryURL.path) {
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    return directoryURL.appendingPathComponent(name, isDirectory: false)
}

private func saveData(_ data: Data, to url: URL) throws {
    try data.write(to: url)
}

private func deleteData(at url: URL) throws {
    let fileManager = Current.fileManager()
    guard fileManager.fileExists(atPath: url.path) else {
        throw Abort(.notFound)
    }
    
    try fileManager.removeItem(at: url)
}

private func fetchData(from url: URL) throws -> Data {
    let fileManager = Current.fileManager()
    guard fileManager.fileExists(atPath: url.path) else {
        throw Abort(.notFound)
    }
    
    return try Data(contentsOf: url)
}
