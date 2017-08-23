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
    
    public func makeMatcher(on target: Matcher.Target.SubSequence) -> Matcher {
        return Matcher(pattern: self, target: target)
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        
        let pattern: GreedyRepetitionPattern
        let target: Target.SubSequence
        var submatchers: [(matcher: Subpattern.Matcher, startIndex: Target.Index)]! = nil
        
        init(pattern: GreedyRepetitionPattern, target: Target.SubSequence) {
            self.pattern = pattern
            self.target = target
        }
        
        mutating func extendSubmatchers(startingAt startIndex: Target.Index) -> Target.Index {
            var index = startIndex
            
            while pattern.counts >= submatchers.count {
                var submatcher = pattern.subpattern.makeMatcher(on: target[index...])
                guard let newMatch = submatcher.next() else {
                    break
                }
                
                submatchers.append((matcher: submatcher, startIndex: index))
                index = newMatch.range.upperBound
            }
            
            return index
        }
        
        mutating func nextIgnoringMinimumCount() -> PatternMatch<Target>? {
            // Initialization
            guard submatchers != nil else {
                self.submatchers = []
                let firstEndIndex = extendSubmatchers(startingAt: target.startIndex)
                return PatternMatch(contents: target[..<firstEndIndex])
            }
            
            guard case (var lastSubmatcher, let index)? = submatchers.popLast() else {
                return nil
            }
            
            let endIndex: Target.Index
            if let nextMatch = lastSubmatcher.next() {
                submatchers.append((lastSubmatcher, index))
                endIndex = extendSubmatchers(startingAt: nextMatch.range.upperBound)
            }
            else {
                endIndex = index
            }
                
            return PatternMatch(contents: target[..<endIndex])
        }
        
        public mutating func next() -> PatternMatch<Target>? {
            var result: PatternMatch<Target>?
            
            repeat {
                result = nextIgnoringMinimumCount()
            } while result != nil && pattern.counts > submatchers.count
            
            return result
        }
    }
}
