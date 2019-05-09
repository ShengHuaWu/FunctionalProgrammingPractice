precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition
func >>> <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) -> C) -> (A) -> C {
    return { a in
        rhs(lhs(a))
    }
}

func >>> <A, B, C>(lhs: @escaping (A) throws -> B, rhs: @escaping (B) throws -> C) -> (A) throws -> C {
    return { a in
        try rhs(lhs(a))
    }
}

func >>> <A, B, C>(lhs: @escaping (A) throws -> B, rhs: @escaping (B) -> C) -> (A) throws -> C {
    return { a in
        rhs(try lhs(a))
    }
}

func >>> <A, B, C>(lhs: @escaping (A) -> B, rhs: @escaping (B) throws -> C) -> (A) throws -> C {
    return { a in
        try rhs(lhs(a))
    }
}
