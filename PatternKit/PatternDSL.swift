//
//  PatternDSL.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public func pattern<P: PatternProtocol>(_ pattern: P) -> P {
    return pattern
}

extension Collection {
    static func pattern<P: PatternProtocol>(_ pattern: P) -> P
        where P.Matcher.Target == Self
    {
        return pattern
    }
}

postfix operator /

public postfix func /<C: Collection, T: Collection>(collection: C) -> CollectionPattern<T, C> {
    return CollectionPattern(collection: collection)
}

public func + <Left: PatternProtocol, Right: PatternProtocol>(lhs: Left, rhs: Right) -> ConcatenationPattern<Left, Right> {
    return ConcatenationPattern(first: lhs, second: rhs)
}

public func | <Left: PatternProtocol, Right: PatternProtocol>(lhs: Left, rhs: Right) -> AlternationPattern<Left, Right> {
    return AlternationPattern(primary: lhs, alternate: rhs)
}

postfix operator +
postfix operator *
postfix operator %

public postfix func +<P: PatternProtocol>(pattern: P) -> GreedyRepetitionPattern<P, PartialRangeFrom<Int>> {
    return GreedyRepetitionPattern(subpattern: pattern, counts: 1...)
}

public postfix func *<P: PatternProtocol>(pattern: P) -> GreedyRepetitionPattern<P, PartialRangeFrom<Int>> {
    return GreedyRepetitionPattern(subpattern: pattern, counts: 0...)
}

public postfix func %<P: PatternProtocol>(pattern: P) -> GreedyRepetitionPattern<P, ClosedRange<Int>> {
    return GreedyRepetitionPattern(subpattern: pattern, counts: 0...1)
}

extension PatternProtocol {
    public func repeating<R>(_ counts: R) -> GreedyRepetitionPattern<Self, R> {
        return GreedyRepetitionPattern(subpattern: self, counts: counts)
    }
    
    public func repeating(_ count: Int) -> GreedyRepetitionPattern<Self, ClosedRange<Int>> {
        return GreedyRepetitionPattern(subpattern: self, counts: count...count)
    }
}

public func any<T: Collection>(where predicate: @escaping (T.Element) -> Bool) -> ElementPredicatePattern<T> {
    return ElementPredicatePattern(predicate: predicate)
}

public func any<T: Collection>(of permitted: Set<T.Element>) -> ElementPredicatePattern<T> {
    return any(where: permitted.contains)
}

public func any<T: Collection, S: SetAlgebra>(of permitted: S) -> ElementPredicatePattern<T>
    where S.Element == T.Element
{
    return any(where: permitted.contains)
}

public func any<T: Collection, S: Sequence>(of permitted: S) -> ElementPredicatePattern<T>
    where S.Element == T.Element
{
    return any(of: Set(permitted))
}

public func any<T: Collection, R: RangeExpression>(of permitted: R) -> ElementPredicatePattern<T>
    where R.Bound == T.Element
{
    return any(where: permitted.contains)
}


public func any<T: Collection>(_ first: T.Element, _ rest: T.Element...) -> ElementPredicatePattern<T>
    where T.Element: Hashable
{
    return any(of: [first] + rest)
}

public func any<T: Collection>() -> ElementPredicatePattern<T> {
    return ElementPredicatePattern { _ in true } 
}

public prefix func !<T>(any: ElementPredicatePattern<T>) -> ElementPredicatePattern<T> {
    let predicate = any.predicate
    return ElementPredicatePattern { !predicate($0) }
} 

