//
//  Parser.swift
//  Parsimmon
//
//  Created by Robert Widmann on 1/14/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

public struct Parser<S, A, B> {
	let fun : Source<S, A> -> (Reply<B>, Source<S, A>)

	public func flatMap<C>(f : B -> Parser<S, A, C>) -> Parser<S, A, C> {
		return Parser<S, A, C>({ s in
			let (r, s) = self.fun(s)
			switch r {
				case .Consume:
					return (.Consume, s)
				case .Failure:
					return (.Failure, s)
				case let .Success(b):
					return f(b).fun(s)
			}
		})
	}
}

public func current<S, A>() -> Parser<S, A, A> {
	return Parser({ s in
		return (.Success(s.cur), s)
	})
}

public func lookAhead<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, B> {
	return Parser({ s in
		let (r, _) = p.fun(s)
		return (r, s)
	})
}

public func negate<S, A, B>(p : Parser<S, A, B>) -> Parser<S, A, ()> {
	return Parser({ s in
		let (r, s) = p.fun(s)
		return (Reply.negate(r), s)
	})
}

public func map<S, A, B, C>(p : Parser<S, A, B>, f : B -> C) -> Parser<S, A, C> {
	return Parser({ s in
		let (r, s) = p.fun(s)
		return (Reply.map(f, r: r), s)
	})
}

public func choose<S, A, B, C>(p : Parser<S, A, B>, f : B -> Optional<C>) -> Parser<S, A, C> {
	return Parser({ s in
		let (r, s) = p.fun(s)
		return (Reply.choose(f, r: r), s)
	})
}

public func <* <S, A, B, C>(p : Parser<S, A, B>, q : Parser<S, A, C>) -> Parser<S, A, B> {
	return Parser({ s in
		let (r, s) = p.fun(s)
		switch r {
			case .Consume:
				return (.Consume, s)
			case .Failure:
				return (.Failure, s)
			case let .Success(p):
				let (r, s) = q.fun(s)
				return (Reply.put(p, r: r), s)
		}
	})
}

public func *> <S, A, B, C>(p : Parser<S, A, B>, q : Parser<S, A, C>) -> Parser<S, A, C> {
	return Parser({ s in
		let (r, s) = p.fun(s)
		switch r {
		case .Consume:
			return (.Consume, s)
		case .Failure:
			return (.Failure, s)
		case let .Success(_):
			return q.fun(s)
		}
	})
}

public func both<S, A, B, C>(p : Parser<S, A, B>, q : Parser<S, A, C>) -> Parser<S, A, (B, C)> {
	return Parser({ s in
		let (r, s) = p.fun(s)
		switch r {
		case .Consume:
			return (.Consume, s)
		case .Failure:
			return (.Failure, s)
		case let .Success(p):
			let (r, s) = q.fun(s)
			return (Reply.map({ q in (p, q) }, r: r), s)
		}
	})
}

public func <|> <S, A, B>(p : Parser<S, A, B>, q : Parser<S, A, B>) -> Parser<S, A, B> {
	return Parser({ s in
		let (r, sp) = p.fun(s)
		switch r {
		case .Consume:
			fallthrough
		case .Failure:
			return q.fun(s)
		case let .Success(p):
			return (.Success(p), sp)
		}
	})
}


