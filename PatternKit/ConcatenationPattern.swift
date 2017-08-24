//
//  ConcatenationPattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct ConcatenationPattern<First: PatternProtocol, Second: PatternProtocol>: PatternProtocol
    where First.Matcher.Target == Second.Matcher.Target, First.Matcher.Captures == Second.Matcher.Captures
{
    public let first: First
    public let second: Second
    
    public var mandatoryPrefix: (elements: [First.Matcher.Target.Element], continuable: Bool) {
        let firstPrefix = first.mandatoryPrefix
        guard firstPrefix.continuable else {
            return firstPrefix
        }
        
        let secondPrefix = second.mandatoryPrefix
        return (firstPrefix.elements + secondPrefix.elements, secondPrefix.continuable)
    }
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher {
        return Matcher(pattern: self, target: target, captures: captures)
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = First.Matcher.Target
        public typealias Captures = First.Matcher.Captures
        
        let pattern: ConcatenationPattern<First, Second>
        let target: Target.SubSequence
        let captures: Captures
        
        var first: First.Matcher
        var second: Second.Matcher?
        
        init(pattern: ConcatenationPattern, target: Target.SubSequence, captures: Captures) {
            self.pattern = pattern
            self.target = target
            self.captures = captures
            
            first = pattern.first.makeMatcher(on: target, with: captures)
            
            second = first.next().map { match in
                pattern.second.makeMatcher(on: target[fromEnd: match.contents], with: match.captures)
            }
        }
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            if let secondMatch = second?.next() {
                return PatternMatch(contents: target[toEnd: secondMatch.contents], captures: secondMatch.captures)
            }
            
            // This didn't work; bump us forward.
            guard let firstMatch = first.next() else {
                return nil
            }
            second = pattern.second.makeMatcher(on: target[fromEnd: firstMatch.contents], with: firstMatch.captures)
            
            // Try again.
            return next()
        }
    }
}

private extension Collection {
    subscript(toEnd subseq: SubSequence) -> SubSequence {
        return self[..<subseq.endIndex]
    }
    subscript(fromEnd subseq: SubSequence) -> SubSequence {
        return self[subseq.endIndex...]
    }
}
