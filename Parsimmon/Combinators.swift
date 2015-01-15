//
//  Combinators.swift
//  Parsimmon
//
//  Created by Robert Widmann on 1/14/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

public func parserZero<S, A, B>() -> Parser<S, A, B> {
	return Parser({ s in
		return (.Failure, s)
	})
}

public func try<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, B> {
	return undefined()
}

public func choice<S, A, B>(ps : [Parser<S, A, B>]) -> Parser<S, A, B> {
	return ps.reduce(parserZero(), combine: <|>)
}

public func option<S, A, B>(x : B, p : Parser<S, A, B>) -> Parser<S, A, B> {
	return p <|> Parser({ s in
		return (.Success(x), s)
	})
}

public func optionMaybe<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, Optional<B>> {
	return option(.None, p.flatMap({ x in
		return Parser({ s in
			return (.Success(x), s)
		})
	}))
}

public func optional<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, ()> {
	return p.flatMap({ _ in
		return Parser({ s in
			return (.Success(()), s)
		})
	}) <|> Parser({ s in
		return (.Success(()), s)
	})
}

public func manyAccum<S, A, B>(acc : B -> [B] -> [B], p : Parser<S, A, B>) -> Parser<S, A, [B]> {
	return undefined()
}

public func many<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, [B]> {
	return Parser({ s in
		let (r, s) = many(p).fun(s)
		return (Reply.choose({ l in
			if l.count == 0 {
				return .None
			}
			return .Some(l)
		}, r: r), s)
	})
}

public func many1<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, [B]> {
	return p.flatMap({ x in
		return many(p).flatMap({ xs in
			return Parser({ s in
				return (.Success([x] + xs), s)
			})
		})
	})
}

public func count<S, A, B>(n : Int, p : Parser<S, A, B>) -> Parser<S, A, [B]> {
	return undefined()
}

public func skipManyMax<S, A, B>(n : Int, Parser<S, A, B>) -> Parser<S, A, Int> {
	return undefined()
}

public func skipMany<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, Int> {
	return undefined()
}

public func skipMany1<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, Int> {
	return Parser({ s in
		let (r, s) = skipMany(p).fun(s)
		return (Reply.choose({ n in
			if n > 0 {
				return .Some(n)
			}
			return .None
		}, r: r), s)
	})
}

public func skipN<S, A, B>(x : Int, p : Parser<S, A, B>) -> Parser<S,  A, ()> {
	return Parser({ s in
		let (r, s) = skipMany(p).fun(s)
		return (Reply.choose({ n in
			if n == x {
				return .Some(())
			}
			return .None
		}, r: r), s)
	})
}