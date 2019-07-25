// TODO: Move to anothet file
struct AnyRandomNumberGenerator: RandomNumberGenerator {
    private var rng: RandomNumberGenerator
    
    init(rng: RandomNumberGenerator) {
        self.rng = rng
    }
    
    mutating func next() -> UInt64  {
        return rng.next()
    }
}

struct Gen<A> {
    let run: (inout AnyRandomNumberGenerator) -> A
}

extension Gen {
    static func element(of xs: [A]) -> Gen<A?> {
        return Gen<A?> { rng in xs.randomElement(using: &rng) }
    }
    
    func array(of count: Gen<Int>) -> Gen<[A]> {
        return count.flatMap { count in
            return Gen<[A]> { rng in
                var array: [A] = []
                for _ in 1...count {
                    array.append(self.run(&rng))
                }
                
                return array
            }
        }
    }
    
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { rng in
            return f(self.run(&rng))
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Gen<B>) -> Gen<B> {
        return Gen<B> { rng in
            let genB = f(self.run(&rng))
            
            return genB.run(&rng)
        }
    }
}

extension Gen where A == Int {
    static func int(in range: ClosedRange<A>) -> Gen {
        return Gen { rng in .random(in: range, using: &rng) }
    }
}

func zip<A, B>(_ genA: Gen<A>, _ genB: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> { rng in (genA.run(&rng), genB.run(&rng)) }
}

func zip<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { genA, genB in zip(genA, genB).map(f) }
}

// TODO: Seed random data
