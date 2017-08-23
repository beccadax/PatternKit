# PatternKit: Collection pattern-matching in Swift

PatternKit is a library for matching patterns in collections. Patterns have many of the basic capabilities of regular expressions, but have a different syntax and can match on any `Collection` of `Hashable` elements.

PatternKit is a proof of concept. It is in an early stage of design and should not be used in production. It currently supports the fundamental features of a regular expression

## Patterns by example

### Basic matching, sequence of elements

The `matches(with:)` method returns a lazy collection with all non-overlapping matches for the pattern throughout the collection being searched.

You can make a pattern for a simple sequence of elements with the postfix `/` operator.

```Swift
let greetingCount = text.matches(with: "hi"/).count
```

### Getting match contents, choosing between two possibilities

`matches(with:)` returns a series of `PatternMatch` instances; each contains a `SubSequence` of the original collection, including its range, which matched the pattern.

Use `|` to match either of two patterns. The leftmost pattern is preferred.

```swift
for match in text.matches(with: "hello"/ | "hi"/) {
    print(match.contents)
}
```

### Getting match ranges, concatenating patterns

`PatternMatch` also contains a `range` for the match.

Use `+` to join two patterns together. The first pattern must match first, then the second.

```swift
for match in text.matches(with: ("hello"/ | "hi"/) + ", world!"/) {
    print(match.range)
}
```

### Pre-constructing patterns, matching elements against possibilities

The `C.pattern(_:)` method lets you pre-construct a pattern to match against a collection of type `C`. You can use this for many purposes, but it's especially handy for subpatterns you use in several places.

Use `any(where:)`, `any(of:)`, `any(_:)`, or `any()` to test an element against an arbitrary predicate, membership in a collection, existence in a list, or simply accept any element. You can negate with a prefix `!`.

```swift
let d = String.pattern(any(of: "0123456789"))
let phoneNumbers = text.matches(with: d+d+d + "-"/ + d+d+d + "-"/ + d+d+d+d)
    .map { $0.contents }.sorted()
```

### Repeating subpatterns

Match a subpattern 0 times or more with `*`, 1 time or more with `+`, 0 or 1 times with `%`, or any other number of times with the `repeating(_: Int)` or `repeating(_: RangeExpression)` methods. Repetitions are greedy and support all the backtracking behavior you would expect from a regular expression.

```swift
let animaniacsCatcalls =
    text.matches(with: "Hell"/ + ("o"/)+ + ", Nurse!")
        .map { $0.contents }
```

### Non-string patterns

Patterns can be matched in any `Collection` of `Hashable` elements not just strings.

PatternKit offers a number of convenience methods on `Collection`, including `firstMatch(with:)`, `ranges(with:)`, `range(with:)`, `index(with:)`, and `contains(_:)`.

```swift
if numbers.contains([1, 2, 3, 4, 5]/) {
    print("That's the stupidest combination I've ever heard in my life!")
}
```

## Custom patterns

You can create your own pattern types by conforming to the `PatternProtocol` protocol. See its documentation for details.

When implementing patterns, you may find the `trace(…)` function useful. It wraps a subpattern so that it prints information about each match it makes.

## Status

**This library is not production-ready.** It is a proof of concept and its interface is likely to change radically in the future. 

### Not yet supported

* Capturing the matches of a subpattern
* Anchored matches
* Lazy and possessive repetititon

### Don't know how to support

* I'd love to get rid of the `/` operator and support treating any `Collection` as a pattern matching its elements, but even with conditional conformance, there's no space for the `Target` associated type.
* Case-insensitive, diacritical-insensitive, and locale-aware matching—passing an `areEquivalent` function at the pattern's top would do it, but that would break `Hashable`-based features like `any(…)` and the internal `SearchSkipper` type.

### Uncertain design questions

* Do we need the `PatternMatch` type, or can we just return a `SubSequence`? This probably depends on how capturing works.
* How many matching methods do we want, and with what sort of naming convention?

### Just need to do

* More thorough tests
* Complete documentation
* Examine performance characteristics

## Author

[Brent Royal-Gordon](https://github.com/brentdax), Architechies. 

## Copyright

© 2017 Architechies. All Rights Reserved.

Distributed under the terms of the MIT License. See LICENSE file for details.

