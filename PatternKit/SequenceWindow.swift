//
//  SequenceWindow.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/23/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

/// Conforming types represent a window of elements from an underlying 
/// `Sequence`. Elements within the window support repeated random 
/// access.
protocol SequenceWindowProtocol: RandomAccessCollection where Index == Int, IndexDistance == Int {
    /// Move the window `offset` elements further in the sequence; that 
    /// is, remove the first `offset` elements from the beginning of the 
    /// window and add `offset` new elements to the end.
    /// 
    /// - Precondition: `offset` must not be negative.
    mutating func advance(by offset: IndexDistance)
}

struct SequenceWindow<Underlying: Sequence>: SequenceWindowProtocol {
    private var underlying: Underlying.Iterator
    private var array: [Underlying.Element]
    private var shifted: Int
    private var dropped: Int
    
    init(underlying: Underlying, count: Int) {
        var _iterator = underlying.makeIterator()
        array = (0..<count).flatMap { _ in _iterator.next() }
        self.underlying = _iterator
        
        shifted = count - array.count
        dropped = 0
    }
    
    var startIndex: Int { return shifted + array.startIndex }
    var endIndex: Int { return shifted - dropped + array.endIndex }
    
    private func physicalIndex(at i: Int) -> Int {
        precondition(startIndex <= i, "\(i) has shifted off the end")
        precondition(i < endIndex, "\(i) has not been retrieved yet")
        
        return i % array.count
    }
    
    private(set) subscript(i: Int) -> Underlying.Element {
        get { return array[physicalIndex(at: i)] }
        set { array[physicalIndex(at: i)] = newValue }
    }
    
    mutating func advance(by count: Int) {
        for _ in 0..<count {
            guard let newElement = underlying.next() else {
                shrink(by: 1)
                return
            }
            
            shift(by: 1)
            self[endIndex - 1] = newElement
        }
    }
    
    private mutating func shift(by count: Int) {
        shifted += count
    }
    
    private mutating func shrink(by count: Int) {
        dropped += count
        shift(by: 1)
    }
}

struct RandomAccessCollectionWindow<Underlying: RandomAccessCollection>: SequenceWindowProtocol {
    private var underlying: Underlying
    private var shifted: Int
    public private(set) var count: Int
    
    init(underlying: Underlying, count: Int) {
        self.underlying = underlying
        self.count = Swift.min(count, numericCast(underlying.count))
        self.shifted = 0
    }
    
    var startIndex: Int {
        return shifted
    }
    var endIndex: Int {
        return shifted + count
    }
    
    private func physicalIndex(at i: Int) -> Underlying.Index {
        precondition(startIndex <= i, "\(i) has shifted off the end")
        precondition(i < endIndex, "\(i) has not been retrieved yet")
        
        return underlying.index(underlying.startIndex, offsetBy: numericCast(i))
    }
    
    subscript(i: Int) -> Underlying.Element {
        get { return underlying[physicalIndex(at: i)] }
    }
    
    mutating func advance(by offset: Int) {
        shifted += offset
        count = Swift.min(offset, numericCast(underlying.count) - shifted)
    }
}

extension Sequence {
    func makeWindow(count: Int) -> SequenceWindow<Self> {
        return SequenceWindow(underlying: self, count: count)
    }
}

extension RandomAccessCollection {
    func makeWindow(count: Int) -> RandomAccessCollectionWindow<Self> {
        return RandomAccessCollectionWindow(underlying: self, count: count)
    }
}
