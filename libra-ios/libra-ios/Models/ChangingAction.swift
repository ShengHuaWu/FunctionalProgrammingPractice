enum ChangingAction<Value> {
    case create(newValue: Value)
    case update(oldValue: Value, newValue: Value)
    case delete(oldValue: Value)
}

extension ChangingAction: Codable where Value: Codable {
    private struct UpdateValuePair: Codable {
        let oldValue: Value
        let newValue: Value
    }
    
    enum CodingKeys: String, CodingKey {
        case create
        case update
        case delete
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let createdValue = try container.decodeIfPresent(Value.self, forKey: .create) {
            self = .create(newValue: createdValue)
        } else if let updateValuePair = try container.decodeIfPresent(UpdateValuePair.self, forKey: .update) {
            self = .update(oldValue: updateValuePair.oldValue, newValue: updateValuePair.newValue)
        } else if let deletedValue = try container.decodeIfPresent(Value.self, forKey: .delete) {
            self = .delete(oldValue: deletedValue)
        } else {
            preconditionFailure("Unsupported decoding for changing action")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .create(let newValue):
            try container.encode(newValue, forKey: .create)
        case let .update(oldValue, newValue):
            let pair = UpdateValuePair(oldValue: oldValue, newValue: newValue)
            try container.encode(pair, forKey: .update)
        case .delete(let oldValue):
            try container.encode(oldValue, forKey: .delete)
        }
    }
}
