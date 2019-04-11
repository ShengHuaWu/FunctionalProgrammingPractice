precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication
func |> <A, B>(lhs: A, rhs: (A) -> B) -> B {
    return rhs(lhs)
}

func |> <A, B>(lhs: A, rhs: (A) throws -> B) throws -> B {
    return try rhs(lhs)
}
