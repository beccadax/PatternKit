//
//  TracePattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public func trace<P: PatternProtocol>(_ pattern: P) -> TracePattern<P> {
    return TracePattern(subpattern: pattern)
}

private var sharedCounter = 0

func formatIndex<Index>(_ i: Index) -> String {
    guard let si = i as? String.Index else {
        return String(describing: i)
    }
    
    return String(si.encodedOffset)
}

public struct TracePattern<Subpattern: PatternProtocol>: PatternProtocol {
    public var subpattern: Subpattern
    
    public var mandatoryPrefix: (elements: [Subpattern.Matcher.Target.Element], continuable: Bool) {
        let prefixInfo = subpattern.mandatoryPrefix
        
        print(
            "Pattern \(subpattern) requires prefix \(prefixInfo.elements)",
            (prefixInfo.continuable ? "(can append more)" : "")
        )
        
        return prefixInfo
    }
    
    public func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher {
        return Matcher(subpattern: subpattern, target: target, captures: captures)
    }
    
    public struct Matcher: PatternMatcher {
        public typealias Target = Subpattern.Matcher.Target
        public typealias Captures = Subpattern.Matcher.Captures
        
        var submatcher: Subpattern.Matcher
        let counter: Int
        
        init(subpattern: Subpattern, target: Target.SubSequence, captures: Captures) {
            self.submatcher = subpattern.makeMatcher(on: target, with: captures)
            
            sharedCounter += 1
            counter = sharedCounter
            
            print(counter, "Matching \(subpattern) at \(formatIndex(target.startIndex)) of [\(target)] with \(captures)")
        }
        
        public mutating func next() -> PatternMatch<Target, Captures>? {
            guard let match = submatcher.next() else {
                print(counter, "    ...exhausted all matches")
                return nil
            }
            
            print(counter, "    ...[\(match.contents)] at \(formatIndex(match.range.upperBound)) with \(match.captures)")
            return match
        }
    }
}

extension AlternationPattern: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(String(reflecting: primary)) | \(String(reflecting: alternate))"
    }
}

extension ConcatenationPattern: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(String(reflecting: first)) + \(String(reflecting: second))"
    }
}

extension CollectionPattern: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(String(reflecting: collection))/"
    }
}

// No shorthand syntax for this
//extension EqualPattern: CustomDebugStringConvertible {
//    public var debugDescription: String {
//        return "/\(String(reflecting: collection))"
//    }
//}

extension GreedyRepetitionPattern: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(\(String(reflecting: subpattern))).repeating(\(counts))"
    }
}

extension TracePattern: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "trace(\(String(reflecting: subpattern)))"
    }
}

