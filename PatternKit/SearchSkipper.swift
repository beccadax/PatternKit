//
//  SearchSkipper.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/23/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

/// Accelerates a search for a given sequence of elements within a 
/// collection.
///
/// Given an array representing a sequence of elements to search for, 
/// the initializer computes a table of offsets for each of the elements. 
/// Calling `skipIndex(in:)` with a collection will then return the index 
/// of the first *possible* match for that sequence of elements. By 
/// using the table of offsets, it avoids repeatedly testing the equality 
/// of every single element.
/// 
/// This type currently implements a version of the
/// [Boyer-Moore-Horspool algorithm](https://en.wikipedia.org/wiki/Boyer-Moore-Horspool_algorithm) 
/// adapted to work with Swift `Collection`. It uses a `Dictionary` 
/// as a sparse array to store the offsets, so its performance may vary 
/// slightly from textbook implementations. This is especially true if the 
/// collection being matched against is not a `RandomAccessCollection` 
/// or enumerating its indices is not an O(1) operation.
/// 
/// - Complexity: O(m) space, where m = size of needle.
struct SearchSkipper<Element: Hashable> {
    // TODO: See if using this is actually faster than less elaborate 
    // alternatives, or if a full Boyer-Moore implementation would be 
    // more useful.
    
    /// Contains the minimum offset in `haystack` at which `needle` 
    /// might be found, given whatever `Element` would be the last 
    /// element of `needle` if `needle` were at this location.
    /// 
    /// In other words, if `needle` were "foobar", `offsets` would be:
    /// 
    ///    [ "f": 5, "o": 3, "b": 2, "a": 1, "r": 0 ] 
    private var offsets: [Element: Int] = [:]
    
    /// The number of elements in the needle; used as a default offset.
    private var count: Int
    
    /// Initializes a skipper which accelerates a search for the 
    /// elements in `needle`.
    /// 
    /// - Parameter needle: The elements to search for.
    /// - Complexity: Amortized O(m).
    init(_ needle: [Element]) {
        count = needle.count
        
        for (offset, element) in needle.reversed().enumerated() {
            if offsets[element] == nil {
                offsets[element] = offset
            }
        }
    }
    
    /// Returns the first index in `haystack` at which the elements in 
    /// the `needle` might be found.
    /// 
    /// This call guarantees that no instance of `haystack` will be 
    /// found before the index at the return value, but does not 
    /// guarantee that it will be found at that index.
    /// 
    /// This private overload exists so that calls using different 
    /// `SequenceWindowProtocol` types can share an implementation. 
    /// 
    /// - Parameter haystack: The collection to search for the `needle`.
    /// - Parameter makeIndexWindow: Function which creates a  
    ///               `SequenceWindow` of `count` indices from `haystack`.
    /// 
    /// - Returns: The first index in `haystack` at which `needle` might 
    ///              be found, or `haystack.endIndex` if it cannot be 
    ///              found anywhere within it.
    private func skipIndex<C: Collection, IndexWindow: SequenceWindowProtocol>(in haystack: C, makeIndexWindow: (_ count: Int) -> IndexWindow) -> C.Index
        where C.Element == Element, IndexWindow.Element == C.Index
    {
        guard count != 0 else {
            return haystack.startIndex
        }
        
        // `indexWindow` contains `count` indices, so `.first` contains 
        // the `.startIndex` of a potential match and `.last` 
        // contains the `index(before: .endIndex)` of it.
        var indexWindow = makeIndexWindow(count)
        
        // When `indexWindow` starts getting too short, we know there's 
        // no match.
        while indexWindow.count == count {
            assert(
                haystack.distance(from: indexWindow.first!, to: indexWindow.last!) == count - 1,
                "Distance between firstIndex and lastIndex not \(count - 1)"
            )
            
            let lastIndex = indexWindow.last!
            let offset = offsets[haystack[lastIndex]] ?? count
            
            guard offset != 0 else {
                let firstIndex = indexWindow.first!
                return firstIndex
            }
            
            indexWindow.advance(by: offset)
        }
        
        return haystack.endIndex
    }
    
    /// Returns the first index in `haystack` at which the elements in 
    /// the `needle` might be found.
    /// 
    /// This call guarantees that no instance of `haystack` will be 
    /// found before the index at the return value, but does not 
    /// guarantee that it will be found at that index.
    /// 
    /// When used with a non-`RandomAccessCollection`, this method 
    /// has additional overhead because it needs to iterate through 
    /// every index and buffer indices.
    /// 
    /// - Parameter haystack: The collection to search for the `needle`.
    /// 
    /// - Returns: The first index in `haystack` at which `needle` might 
    ///              be found, or `haystack.endIndex` if it cannot be 
    ///              found anywhere within it.
    /// 
    /// - Complexity: O(n), if used after every search.
    func skipIndex<C: Collection>(in haystack: C) -> C.Index
        where C.Element == Element
    {
        return skipIndex(in: haystack, makeIndexWindow: haystack.indices.makeWindow)
    }
    
    /// Returns the first index in `haystack` at which the elements in 
    /// the `needle` might be found.
    /// 
    /// This call guarantees that no instance of `haystack` will be 
    /// found before the index at the return value, but does not 
    /// guarantee that it will be found at that index.
    /// 
    /// When used with a `RandomAccessCollection`, this method is 
    /// optimized to use less time and space.
    /// 
    /// - Parameter haystack: The collection to search for the `needle`.
    /// 
    /// - Returns: The first index in `haystack` at which `needle` might 
    ///              be found, or `haystack.endIndex` if it cannot be 
    ///              found anywhere within it.
    /// 
    /// - Complexity: I think it's technically O(n).
    func skipIndex<C: RandomAccessCollection>(in haystack: C) -> C.Index
        where C.Element == Element
    {
        return skipIndex(in: haystack, makeIndexWindow: haystack.indices.makeWindow as (Int) -> RandomAccessCollectionWindow)
    }
}
