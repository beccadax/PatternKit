//
//  ElementPredicatePattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct ElementPredicatePattern<T: Collection, C>: SimplePattern
    where T.SubSequence: Collection, T.Element: Hashable
{
    public typealias Target = T
    public typealias Captures = C
    
    public let predicate: (T.Element) -> Bool
    
    public var mandatoryPrefix: (elements: [T.Element], continuable: Bool) {
        return ([], false)
    }
        
    internal func match(on target: T.SubSequence, with captures: Captures) -> PatternMatch<Target, Captures>? {
        guard let elem = target.first, predicate(elem) else {
            return nil
        }
        
        return PatternMatch(contents: target[...target.startIndex], captures: captures)
    }
}
