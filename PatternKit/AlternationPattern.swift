//
//  AlternationPattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct AlternationPattern<Primary: PatternProtocol, Alternate: PatternProtocol>: PatternProtocol
    where Primary.Matcher.Target == Alternate.Matcher.Target, Primary.Matcher.Captures == Alternate.Matcher.Captures
{
    public let primary: Primary
    public let alternate: Alternate
    
    public var mandatoryPrefix: (elements: [Primary.Matcher.Target.Element], continuable: Bool) {
        let primaryPrefix = primary.mandatoryPrefix.elements
        let alternatePrefix = alternate.mandatoryPrefix.elements
        
        return (zip(primaryPrefix, alternatePrefix).prefix(while: ==).map { $0.0 }, false)
    }
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher {
        return .primary(primary.makeMatcher(on: target, with: captures), alternate.makeMatcher(on: target, with: captures))
    }

    public enum Matcher: PatternMatcher {
        public typealias Target = Primary.Matcher.Target
        public typealias Captures = Primary.Matcher.Captures
        
        case primary(Primary.Matcher, Alternate.Matcher)
        case alternate(Alternate.Matcher)
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            if case .primary(var primaryMatcher, let alternateMatcher) = self {
                if let nextMatch = primaryMatcher.next() {
                    self = .primary(primaryMatcher, alternateMatcher)
                    return nextMatch
                }
                else {
                    self = .alternate(alternateMatcher)
                }
            }
            
            if case .alternate(var alternateMatcher) = self {
                if let nextMatch = alternateMatcher.next() {
                    self = .alternate(alternateMatcher)
                    return nextMatch
                }
            }
            
            return nil
        }
    }
}
