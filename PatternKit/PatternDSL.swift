//
//  PatternDSL.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public func pattern<P: PatternProtocol>(_ pattern: P) -> P
    where P.Matcher.Captures == Void
{
    return pattern
}

extension Collection {
    static func pattern<P: PatternProtocol>(_ pattern: P) -> P
        where P.Matcher.Target == Self, P.Matcher.Captures == Void
    {
        return pattern
    }
}

postfix operator /

public postfix func /<C: Collection, T: Collection, Captures>(collection: C) -> CollectionPattern<T, C, Captures> {
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

public func any<T: Collection, Captures>(where predicate: @escaping (T.Element) -> Bool) -> ElementPredicatePattern<T, Captures> {
    return ElementPredicatePattern(predicate: predicate)
}

public func any<T: Collection, Captures>(of permitted: Set<T.Element>) -> ElementPredicatePattern<T, Captures> {
    return any(where: permitted.contains)
}

public func any<T: Collection, S: SetAlgebra, Captures>(of permitted: S) -> ElementPredicatePattern<T, Captures>
    where S.Element == T.Element
{
    return any(where: permitted.contains)
}

public func any<T: Collection, S: Sequence, Captures>(of permitted: S) -> ElementPredicatePattern<T, Captures>
    where S.Element == T.Element
{
    return any(of: Set(permitted))
}

public func any<T: Collection, R: RangeExpression, Captures>(of permitted: R) -> ElementPredicatePattern<T, Captures>
    where R.Bound == T.Element
{
    return any(where: permitted.contains)
}


public func any<T: Collection, Captures>(_ first: T.Element, _ rest: T.Element...) -> ElementPredicatePattern<T, Captures>
    where T.Element: Hashable
{
    return any(of: [first] + rest)
}

public func any<T: Collection, Captures>() -> ElementPredicatePattern<T, Captures> {
    return ElementPredicatePattern { _ in true } 
}

public prefix func !<T, Captures>(any: ElementPredicatePattern<T, Captures>) -> ElementPredicatePattern<T, Captures> {
    let predicate = any.predicate
    return ElementPredicatePattern { !predicate($0) }
} 

public func capture<Subpattern: PatternProtocol>(_ pattern: Subpattern, from startingValue: Subpattern.Matcher.Captures) -> CapturePattern<Subpattern> {
    return CapturePattern(subpattern: pattern, startingValue: startingValue)
}

public func capture<Subpattern: PatternProtocol>(_ pattern: Subpattern) -> CapturePattern<Subpattern>
    where Subpattern.Matcher.Captures == Void
{
    return capture(pattern, from: ())
}

extension PatternProtocol {
    public func into<Captures>(_ keyPath: WritableKeyPath<Captures, Matcher.Captures>) -> CaptureIntoPattern<Self, Captures> {
        return CaptureIntoPattern(subpattern: self, keyPath: keyPath)
    }
}

extension PatternProtocol {
    public func map<TransformedCaptures>(from startingValue: Matcher.Captures, transform: @escaping (Matcher.Captures) -> TransformedCaptures) -> CaptureMapPattern<Self, TransformedCaptures> {
        return CaptureMapPattern(subpattern: self, startingValue: startingValue, transform: transform)
    }
}

extension PatternProtocol where Matcher.Captures: ExpressibleByNilLiteral {
    public func map<TransformedCaptures>(transform: @escaping (Matcher.Captures) -> TransformedCaptures) -> CaptureMapPattern<Self, TransformedCaptures> {
        return CaptureMapPattern(subpattern: self, startingValue: nil, transform: transform)
    }
}

extension PatternProtocol where Matcher.Captures: RangeReplaceableCollection {
    public func map<TransformedCaptures>(transform: @escaping (Matcher.Captures) -> TransformedCaptures) -> CaptureMapPattern<Self, TransformedCaptures> {
        return CaptureMapPattern(subpattern: self, startingValue: Matcher.Captures(), transform: transform)
    }
}

