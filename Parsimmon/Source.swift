//
//  Source.swift
//  Parsimmon
//
//  Created by Robert Widmann on 1/14/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

public struct Source<S, A> {
	let state : S
	let cur : A

	init(_ state : S, _ cur : A) {
		self.state = state
		self.cur = cur
	}
}

public enum Reply<A> {
	case Success(A)
	case Failure
	case Consume

	var isMatch : Bool {
		switch self {
			case .Consume:
				fallthrough
			case .Failure:
				return false
			case .Success(_):
				return true
		}
	}

	static public func fromBool(b : Bool) -> Reply<()> {
		if b {
			return .Success(())
		}
		return .Failure
	}

	static public func negate(r : Reply<A>) -> Reply<()> {
		switch r {
		case .Consume:
			return .Consume
		case .Failure:
			return .Success(())
		case .Success(_):
			return .Failure
		}
	}

	static public func toOption(r : Reply<A>) -> Optional<A> {
		switch r {
		case .Consume:
			fallthrough
		case .Failure:
			return .None
		case let .Success(x):
			return .Some(x)
		}
	}

	static public func put<B>(x : B, r : Reply<A>) -> Reply<B> {
		switch r {
		case .Consume:
			return .Consume
		case .Failure:
			return .Failure
		case .Success(_):
			return .Success(x)
		}
	}

	static public func map<B>(f : A -> B, r : Reply<A>) -> Reply<B> {
		switch r {
		case .Consume:
			return .Consume
		case .Failure:
			return .Failure
		case let .Success(x):
			return .Success(f(x))
		}
	}

	static public func choose<B>(f : A -> Optional<B>, r : Reply<A>) -> Reply<B> {
		switch r {
		case .Consume:
			return .Consume
		case .Failure:
			return .Failure
		case let .Success(x):
			switch f(x) {
			case let .Some(v):
				return .Success(v)
			case .None:
				return .Failure
			}
		}
	}
}



