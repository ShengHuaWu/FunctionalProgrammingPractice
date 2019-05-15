struct Future<A> {
    let run: (@escaping (A) -> Void) -> Void
}

extension Future {
    func map<B>(_ f: @escaping (A) -> B) -> Future<B> {
        return Future<B> { callback in
            self.run { a in
                let b = f(a)
                callback(b)
            }
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Future<B>) -> Future<B> {
        return Future<B> { callback in
            self.run { a in
                let futureB = f(a)
                futureB.run { b in
                    callback(b)
                }
            }
        }
    }
}
