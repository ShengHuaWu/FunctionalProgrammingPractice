import Foundation

struct Dependencies {
    var fileManager: () -> FileManager = FileManager.init
    var resourcePersisting = ResourcePersisting()
}

var Current = Dependencies()
