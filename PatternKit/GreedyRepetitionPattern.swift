//
//  GreedyRepetitionPattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct GreedyRepetitionPattern<Subpattern: PatternProtocol, CountRange: ComparableRangeExpression>: PatternProtocol
    where CountRange.Bound == Int
{
    public let subpattern: Subpattern
    public let counts: CountRange
    
    public var mandatoryPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) {
        guard !counts.contains(0) else {
            return ([], false)
        }
        
        let aPrefix = subpattern.mandatoryPrefix
        var combinedPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) = ([], true)
        
        for i in 0... {
            guard !counts.contains(i) else {
                // We've hit the minimum. If this is also the maximum,
                // the prefix can be continued.
                combinedPrefix.continuable = aPrefix.continuable && !counts.contains(i + 1)
                break
            }
            
            combinedPrefix.elements += aPrefix.elements
            
            guard aPrefix.continuable else {
                combinedPrefix.continuable = aPrefix.continuable
                break
            }
        }
        
        return combinedPrefix
    }
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher {
        return Matcher(pattern: self, target: target, captures: captures)
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        public typealias Captures = Subpattern.Matcher.Captures
        
        let pattern: GreedyRepetitionPattern
        let target: Target.SubSequence
        let startCaptures: Captures
        
        var submatchers: [(matcher: Subpattern.Matcher, startIndex: Target.Index, startCaptures: Captures)]! = nil
        
        init(pattern: GreedyRepetitionPattern, target: Target.SubSequence, captures: Captures) {
            self.pattern = pattern
            self.target = target
            self.startCaptures = captures
        }
        
        mutating func extendSubmatchers(startingAt startIndex: Target.Index, with startCaptures: Captures) -> (Target.Index, Captures) {
            var index = startIndex
            var captures = startCaptures
            
            while pattern.counts >= submatchers.count {
                var submatcher = pattern.subpattern.makeMatcher(on: target[index...], with: captures)
                guard let newMatch = submatcher.next() else {
                    break
                }
                
                submatchers.append((matcher: submatcher, startIndex: index, startCaptures: captures))
                index = newMatch.range.upperBound
                captures = newMatch.captures
            }
            
            return (index, captures)
        }
        
        mutating func nextIgnoringMinimumCount() -> PatternMatch<Target, Captures>? {
            // Initialization
            guard submatchers != nil else {
                self.submatchers = []
                let (firstEndIndex, firstEndCaptures) = extendSubmatchers(startingAt: target.startIndex, with: startCaptures)
                return PatternMatch(contents: target[..<firstEndIndex], captures: firstEndCaptures)
            }
            
            guard case (var lastSubmatcher, let index, let captures)? = submatchers.popLast() else {
                return nil
            }
            
            let endIndex: Target.Index
            let endCaptures: Captures
            
            if let nextMatch = lastSubmatcher.next() {
                submatchers.append((lastSubmatcher, index, captures))
                (endIndex, endCaptures) = extendSubmatchers(startingAt: nextMatch.range.upperBound, with: nextMatch.captures)
            }
            else {
                endIndex = index
                endCaptures = captures
            }
                
            return PatternMatch(contents: target[..<endIndex], captures: endCaptures)
        }
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            var result: PatternMatch<Target, Captures>?
            
            repeat {
                result = nextIgnoringMinimumCount()
            } while result != nil && pattern.counts > submatchers.count
            
            return result
        }
    }
}
