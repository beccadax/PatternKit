//
//  ComparableRangeExpression.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

public protocol ComparableRangeExpression: RangeExpression {
    static func > (range: Self, value: Bound) -> Bool
    static func < (range: Self, value: Bound) -> Bool
}

extension ComparableRangeExpression {
    static func >= (range: Self, value: Bound) -> Bool {
        return range > value || range.contains(value)
    }
    static func <= (range: Self, value: Bound) -> Bool {
        return range < value || range.contains(value)
    }
    
    static func > (value: Bound, range: Self) -> Bool {
        return range < value
    }
    static func < (value: Bound, range: Self) -> Bool {
        return range > value
    }
    static func >= (value: Bound, range: Self) -> Bool {
        return range <= value
    }
    static func <= (value: Bound, range: Self) -> Bool {
        return range >= value
    }
}

extension Range: ComparableRangeExpression {
    public static func > (range: Range, value: Bound) -> Bool {
        return range.lowerBound > value
    }
    
    public static func < (range: Range, value: Bound) -> Bool {
        return range.upperBound <= value
    }
}

extension CountableRange: ComparableRangeExpression {
    public static func > (range: CountableRange, value: Bound) -> Bool {
        return range.lowerBound > value
    }
    
    public static func < (range: CountableRange, value: Bound) -> Bool {
        return range.upperBound <= value
    }
}

extension ClosedRange: ComparableRangeExpression {
    public static func > (range: ClosedRange, value: Bound) -> Bool {
        return range.lowerBound > value
    }
    
    public static func < (range: ClosedRange, value: Bound) -> Bool {
        return range.upperBound < value
    }
}

extension CountableClosedRange: ComparableRangeExpression {
    public static func > (range: CountableClosedRange, value: Bound) -> Bool {
        return range.lowerBound > value
    }
    
    public static func < (range: CountableClosedRange, value: Bound) -> Bool {
        return range.upperBound < value
    }
}

extension PartialRangeFrom: ComparableRangeExpression {
    public static func > (range: PartialRangeFrom, value: Bound) -> Bool {
        return range.lowerBound > value
    }
    
    public static func < (range: PartialRangeFrom, value: Bound) -> Bool {
        return false
    }
}

extension PartialRangeUpTo: ComparableRangeExpression {
    public static func > (range: PartialRangeUpTo, value: Bound) -> Bool {
        return false
    }
    
    public static func < (range: PartialRangeUpTo, value: Bound) -> Bool {
        return range.upperBound <= value
    }
}

extension PartialRangeThrough: ComparableRangeExpression {
    public static func > (range: PartialRangeThrough, value: Bound) -> Bool {
        return false
    }
    
    public static func < (range: PartialRangeThrough, value: Bound) -> Bool {
        return range.upperBound < value
    }
}
