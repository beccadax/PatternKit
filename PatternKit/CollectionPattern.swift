//
//  CollectionPattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct CollectionPattern<T: Collection, CollectionType: Collection, C>: SimplePattern
    where T.SubSequence: Collection, T.Element == CollectionType.Element, T.Element: Hashable
{
    public typealias Target = T
    public typealias Captures = C
    
    public let collection: CollectionType
    
    public var mandatoryPrefix: (elements: [T.Element], continuable: Bool) {
        return (Array(collection), true)
    }
    
    internal func match(on target: T.SubSequence, with captures: Captures) -> PatternMatch<Target, Captures>? {
        let count: T.SubSequence.IndexDistance = numericCast(collection.count)
        guard let endIndex = target.index(target.startIndex, offsetBy: count, limitedBy: target.endIndex) else {
            return nil
        }
        
        let subtarget = target[..<endIndex]
        
        guard zip(subtarget, collection).all(==) else {
            return nil
        }
        
        return PatternMatch(contents: subtarget, captures: captures)
    }
}

extension Sequence {
    func all(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for elem in self {
            if try !predicate(elem) {
                return false
            }
        }
        return true
    }
}
