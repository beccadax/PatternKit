//
//  CapturePattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/23/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct CapturePattern<Subpattern: PatternProtocol>: PatternProtocol {
    let subpattern: Subpattern
    let startingValue: Subpattern.Matcher.Captures
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher {
        return Matcher(submatcher: subpattern.makeMatcher(on: target, with: startingValue))
    }
    
    public var mandatoryPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) {
        return subpattern.mandatoryPrefix
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        public typealias Captures = Target.SubSequence
        
        var submatcher: Subpattern.Matcher
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            guard let match = submatcher.next() else {
                return nil
            }
            return PatternMatch(contents: match.contents, captures: match.contents)
        }
    }
}

public struct CaptureIntoPattern<Subpattern: PatternProtocol, C>: PatternProtocol {
    let subpattern: Subpattern
    let keyPath: WritableKeyPath<C, Subpattern.Matcher.Captures>
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: C) -> Matcher {
        return Matcher(earlierCaptures: captures, keyPath: keyPath, submatcher: subpattern.makeMatcher(on: target, with: captures[keyPath: keyPath]))
    }
    
    public var mandatoryPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) {
        return subpattern.mandatoryPrefix
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        public typealias Captures = C
        
        let earlierCaptures: Captures
        let keyPath: WritableKeyPath<Captures, Subpattern.Matcher.Captures>
        var submatcher: Subpattern.Matcher
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            guard let match = submatcher.next() else {
                return nil
            }
            
            var captures = earlierCaptures
            captures[keyPath: keyPath] = match.captures
            return PatternMatch(contents: match.contents, captures: captures)
        }
    }
}

public struct CaptureMapPattern<Subpattern: PatternProtocol, TransformedCaptures>: PatternProtocol {
    let subpattern: Subpattern
    let startingValue: Subpattern.Matcher.Captures
    let transform: (Subpattern.Matcher.Captures) -> TransformedCaptures
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: TransformedCaptures) -> Matcher {
        return Matcher(transform: transform, submatcher: subpattern.makeMatcher(on: target, with: startingValue))
    }
    
    public var mandatoryPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) {
        return subpattern.mandatoryPrefix
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        public typealias Captures = TransformedCaptures
        
        let transform: (Subpattern.Matcher.Captures) -> TransformedCaptures
        var submatcher: Subpattern.Matcher
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            guard let match = submatcher.next() else {
                return nil
            }
            
            return PatternMatch(contents: match.contents, captures: transform(match.captures))
        }
    }
}
