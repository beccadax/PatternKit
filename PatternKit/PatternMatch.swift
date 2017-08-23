//
//  PatternMatch.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public struct PatternMatch<Target: Collection>
    where Target.SubSequence: Collection
{
    public let contents: Target.SubSequence
    
    public var range: Range<Target.Index> {
        return contents.startIndex ..< contents.endIndex
    }
}
