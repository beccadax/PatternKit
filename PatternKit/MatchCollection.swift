//
//  MatchCollection.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct MatchCollection<P: PatternProtocol>: Collection {
    public struct Index: Comparable {
        let counter: Int
        let state: (match: PatternMatch<P.Matcher.Target, P.Matcher.Captures>, nextMatcher: FloatingStartPattern<P>.Matcher)?
        
        init(counter: Int, matcher: FloatingStartPattern<P>.Matcher?) {
            var nextMatcher = matcher
            
            guard let match = nextMatcher?.next() else {
                self.counter = .max
                self.state = nil
                return
            }
            
            self.counter = counter
            self.state = (match, nextMatcher!)
        }
        
        public static func == (lhs: Index, rhs: Index) -> Bool {
            return lhs.counter == rhs.counter
        }
        
        public static func < (lhs: Index, rhs: Index) -> Bool {
            return lhs.counter < rhs.counter
        }
    }
    
    init(target: P.Matcher.Target.SubSequence, pattern: P, captures: P.Matcher.Captures) {
        let realPattern = FloatingStartPattern(subpattern: pattern)
        initialMatcher = realPattern.makeMatcher(on: target, with: captures)
    }
    
    let initialMatcher: FloatingStartPattern<P>.Matcher
    
    public var startIndex: Index {
        return Index(counter: 0, matcher: initialMatcher)
    }
    
    public var endIndex: Index {
        return Index(counter: .max, matcher: nil)
    }
    
    public var underestimatedCount: Int {
        return 0
    }
    
    public func index(after i: Index) -> Index {
        return Index(counter: i.counter + 1, matcher: i.state!.nextMatcher)
    }
    
    public subscript(i: Index) -> PatternMatch<P.Matcher.Target, P.Matcher.Captures> {
        return i.state!.match
    }
}

public extension Collection where SubSequence: Collection {
    public func matches<P: PatternProtocol>(with pattern: P) -> MatchCollection<P>
        where P.Matcher.Target == Self, P.Matcher.Captures == ()
    {
        return MatchCollection(target: self[self.startIndex...], pattern: pattern, captures: ())
    }
    
    public func match<P: PatternProtocol>(with pattern: P) -> PatternMatch<Self, P.Matcher.Captures>?
        where P.Matcher.Target == Self, P.Matcher.Captures == ()
    {
        return matches(with: pattern).first
    }
}

public extension Collection where SubSequence: Collection {
    public func ranges<P: PatternProtocol>(with pattern: P) -> LazyMapCollection<MatchCollection<P>, Range<Index>>
        where P.Matcher.Target == Self, P.Matcher.Captures == ()
    {
        return matches(with: pattern).lazy.map { $0.range }
    }

    func range<P: PatternProtocol>(with pattern: P) -> Range<Index>?
        where P.Matcher.Target == Self, P.Matcher.Captures == ()
    {
        return match(with: pattern)?.range
    }
    
    func index<P: PatternProtocol>(with pattern: P) -> Index?
        where P.Matcher.Target == Self, P.Matcher.Captures == ()
    {
        return range(with: pattern)?.lowerBound
    }
    
    func contains<P: PatternProtocol>(with pattern: P) -> Bool
        where P.Matcher.Target == Self, P.Matcher.Captures == ()
    {
        return match(with: pattern) != nil
    }
}

public func ~= <P: PatternProtocol, C>(lhs: P, rhs: C) -> Bool where P.Matcher.Target == C, P.Matcher.Captures == ()
{
    return rhs.contains(with: lhs)
}
