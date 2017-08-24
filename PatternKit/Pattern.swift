//
//  Pattern.swift
//  PatternKit
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

/// Conforming types describe patterns of elements in a collection. 
/// 
/// A pattern can be matched against a collection to find a slice of 
/// the collection with the structure described by that pattern. For 
/// instance, the following pattern describes either of the strings 
/// `"hi"` or `"hello"`:
/// 
///     let greeting = String.pattern("hi"/ | "hello"/)
/// 
/// You can find matches in a string using the `matches(with:)` 
/// method on `Collection`:
/// 
///     for match in myText.matches(with: greeting) {
///         print(match.contents)
///     }
/// 
/// Although these examples show patterns of characters in strings, 
/// patterns can be used with any `Collection` of `Hashable` elements. 
/// This code matches a poor luggage combination:
/// 
///     if numbers.contains([1, 2, 3, 4, 5]/) {
///         print("That's the stupidest combination I've ever heard in my life!")
///     }
/// 
/// Patterns support most of the basic capabilites of a regular 
/// expression, including concatenation, alternation, and greedy 
/// quantifiers. They can also be extended to support new types of 
/// matches.
public protocol PatternProtocol {
    /// An iterator which enumerates all possible matches of the 
    /// pattern anchored at the beginning of a given target collection.
    /// 
    /// - Warning: Although `IteratorProtocol` in general treats 
    ///              copying an iterator as undefined behavior, 
    ///              `PatternMatcher` iterators must allow copying and 
    ///              provide value semantics.
    associatedtype Matcher: PatternMatcher
    
    /// Creates a `Matcher` which iterates over all possible matches 
    /// for this pattern anchored at the beginning of the given `target`, 
    /// from most preferred to least preferred.
    /// 
    /// - Parameter target: The portion of the collection which should 
    ///               be matched against this pattern.
    /// - Returns: A `Matcher` which returns all possible matches.
    /// - Postcondition: All matches returned by `Matcher` have 
    ///                    `target.startIndex` as their `range.lowerBound`.
    func makeMatcher(on target: Matcher.Target.SubSequence, with captures: Matcher.Captures) -> Matcher
    
    /// Returns a series of elements which must be present at the 
    /// beginning of any `target` passed to `makeMatcher(on:)` if it 
    /// is going to succeed. `continuable` should be true if other 
    /// patterns may append their `mandatoryPrefix` elements to these,  
    /// or `false` otherwise.
    /// 
    /// This property can be used to optimize searches by rejecting  
    /// indices which cannot possibly match. 
    /// 
    /// - Warning: I have not tested whether using this property 
    ///              actually improves performance; I happen to know 
    ///              that Perl uses an optimization like this one, and 
    ///              wanted to see if `PatternProtocol` would allow 
    ///              enough information to flow through it for 
    ///              optimizations like this one to be used. Consider this 
    ///              a proof of concept.
    var mandatoryPrefix: (elements: [Matcher.Target.Element], continuable: Bool) { get }
}

/// A `PatternMatcher` is an iterator which returns `PatternMatch` 
/// instances for each matching subsequence of its `Target`.
/// 
/// - Warning: Although `IteratorProtocol` in general treats copying an 
///              iterator as undefined behavior, `PatternMatcher` iterators 
///              must allow copying and provide value semantics.
public protocol PatternMatcher: Sequence, IteratorProtocol where Element == PatternMatch<Target, Captures> {
    associatedtype Target where Target.Element: Hashable
    associatedtype Captures
}

/// A simple pattern is one which can only match in one way, so there 
/// is no need to explore a large number of potential matches.
internal protocol SimplePattern: PatternProtocol where Matcher == SimplePatternMatcher<Target, Captures> {
    associatedtype Target
    associatedtype Captures
    func match(on target: Target.SubSequence, with captures: Matcher.Captures) -> PatternMatch<Target, Captures>?
}

public struct SimplePatternMatcher<T: Collection, C>: PatternMatcher
    where T.SubSequence: Collection, T.Element: Hashable
{
    public typealias Target = T
    public typealias Captures = C
    
    var value: PatternMatch<Target, Captures>?
    
    init(_ value: PatternMatch<Target, Captures>?) {
        self.value = value
    }
    
    public mutating func next() -> PatternMatch<Target, Captures>? {
        defer { value = nil }
        return value
    }
}

extension SimplePattern {
    public func makeMatcher(on target: Target.SubSequence, with captures: Captures) -> SimplePatternMatcher<Target, Captures> {
        return SimplePatternMatcher(match(on: target, with: captures))
    }
}
