//
//  FloatingStartPattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/20/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

/// This is a special pattern which only slots in at the beginning. It 
/// provides the "bump-along" behavior that allows a Pattern to match  
/// anywhere in a Collection.
struct FloatingStartPattern<Subpattern: PatternProtocol>: PatternProtocol {
    let subpattern: Subpattern
    public var mandatoryPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) {
        return subpattern.mandatoryPrefix
    }
    
    /// Pre-calculated search skipper for the `mandatoryPrefix` of the 
    /// pattern.
    private let prefixSearcher: SearchSkipper<Matcher.Target.Element>
    
    init(subpattern: Subpattern) {
        self.subpattern = subpattern
        prefixSearcher = SearchSkipper(subpattern.mandatoryPrefix.elements)
    }
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher {
        return Matcher(pattern: self, target: target, captures: captures)
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        public typealias Captures = Subpattern.Matcher.Captures
        
        let pattern: FloatingStartPattern
        let captures: Captures
        var target: Target.SubSequence
                
        init(pattern: FloatingStartPattern, target: Target.SubSequence, captures: Captures) {
            self.pattern = pattern
            self.captures = captures
            self.target = target
        }
        
        private mutating func bump(toAfter index: Target.Index) -> Bool {
            guard index != target.endIndex else {
                return false
            }
            
            bump(to: target.index(after: index))
            return true
        }
        
        private mutating func bump(to index: Target.Index) {
            target = target[index...]
        }
        
        /// Advances the `startIndex` of `target` to an index which, 
        /// according to the pattern's `mandatoryPrefix`, might match 
        /// the pattern. Uses a Boyer-Moore-Horspool-like search for 
        /// efficiency.
        private mutating func skipAheadToMatchingPrefix() {
            let potentialMatchIndex = pattern.prefixSearcher.skipIndex(in: target)
            
            if potentialMatchIndex != target.startIndex {
//                print("Skipped from \(formatIndex(target.startIndex)) to \(formatIndex(potentialMatchIndex))")
                
                target = target[potentialMatchIndex...]
            }
            else {
//                print("No skip from \(formatIndex(target.startIndex)) to \(formatIndex(potentialMatchIndex))")
            }
        }
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            repeat {
                skipAheadToMatchingPrefix()
                var submatcher = pattern.subpattern.makeMatcher(on: target, with: captures)
                
                // If there's a match at this location, return it.
                if let match = submatcher.next() {
                    // But first, bump past this match.
                    // If the match is empty, we want to move one past the end if possible; if it's not empty, or we can't, we just move to the end.
                    if !match.range.isEmpty || !bump(toAfter: match.range.upperBound) {
                        bump(to: match.range.upperBound) 
                    }
                    
                    return match
                }
            } while bump(toAfter: target.startIndex)
            
            return nil
        }
    }
}
