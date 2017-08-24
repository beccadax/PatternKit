//
//  PatternMatch.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct PatternMatch<Target: Collection, Captures>
    where Target.SubSequence: Collection
{
    public let contents: Target.SubSequence
    public let captures: Captures
    
    public var range: Range<Target.Index> {
        return contents.startIndex ..< contents.endIndex
    }
}
