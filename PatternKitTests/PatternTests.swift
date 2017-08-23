//
//  PatternTests.swift
//  PatternKitTests
//
//  Created by Brent Royal-Gordon on 8/19/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

import XCTest
@testable import PatternKit

class PatternTests: XCTestCase {
    func testCollectionPattern() {
        assertMatches(with: "hello"/, on: "hello hello hello", areLike: [
            .match(contents: "hello", startOffset: 0, endOffset: 5),
            .match(contents: "hello", startOffset: 6, endOffset: 11),
            .match(contents: "hello", startOffset: 12, endOffset: 17)
        ])
    }
    
    func testAlternationPattern() {
        
    }
    
    func testConcatenationPattern() {
        
    }
    
    func testElementPredicatePattern() {
        
    }
    
    func testFloatingStartPattern() {
        
    }
    
    func testGreedyRepetitionPattern() {
        // Tests with 0... (*)
        let hi0 = String.pattern("h"/ + ("i"/)*)
        
        assertMatches(with: hi0, on: "h", areLike: [
            .match(contents: "h", startOffset: 0, endOffset: 1)
        ])
        assertMatches(with: hi0, on: "hi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2)
        ])
        assertMatches(with: hi0, on: "hii", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3)
        ])
        assertMatches(with: hi0, on: "hiii", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4)
        ])
        assertMatches(with: hi0, on: "hoi", areLike: [
            .match(contents: "h", startOffset: 0, endOffset: 1)
        ])
        
        assertMatches(with: hi0, on: "hh", areLike: [
            .match(contents: "h", startOffset: 0, endOffset: 1),
            .match(contents: "h", startOffset: 1, endOffset: 2)
        ])
        assertMatches(with: hi0, on: "hih", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2),
            .match(contents: "h", startOffset: 2, endOffset: 3)
        ])
        assertMatches(with: hi0, on: "hiih", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3),
            .match(contents: "h", startOffset: 3, endOffset: 4)
        ])
        assertMatches(with: hi0, on: "hiiih", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4),
            .match(contents: "h", startOffset: 4, endOffset: 5)
        ])
        assertMatches(with: hi0, on: "hoih", areLike: [
            .match(contents: "h", startOffset: 0, endOffset: 1),
            .match(contents: "h", startOffset: 3, endOffset: 4)
        ])
        
        // Tests with 1... (+)
        let hi1 = String.pattern("h"/ + ("i"/)+)
        
        assertNoMatches(with: hi1, on: "h")
        assertMatches(with: hi1, on: "hi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2)
        ])
        assertMatches(with: hi1, on: "hii", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3)
        ])
        assertMatches(with: hi1, on: "hiii", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4)
        ])
        assertNoMatches(with: hi1, on: "hoi")
        
        assertMatches(with: hi1, on: "hhi", areLike: [
            .match(contents: "hi", startOffset: 1, endOffset: 3)
        ])
        assertMatches(with: hi1, on: "hihi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2),
            .match(contents: "hi", startOffset: 2, endOffset: 4)
        ])
        assertMatches(with: hi1, on: "hiihi", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3),
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
        assertMatches(with: hi1, on: "hiiihi", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4),
            .match(contents: "hi", startOffset: 4, endOffset: 6)
        ])
        assertMatches(with: hi1, on: "hoihi", areLike: [
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
        
        // Tests requiring iteration of submatches
        let hiho = String.pattern("h"/ + any("i", "o")+)
        
        assertNoMatches(with: hiho, on: "h")
        assertMatches(with: hiho, on: "hi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2)
        ])
        assertMatches(with: hiho, on: "hii", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3)
        ])
        assertMatches(with: hiho, on: "hiii", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4)
        ])
        assertMatches(with: hiho, on: "hoi", areLike: [
            .match(contents: "hoi", startOffset: 0, endOffset: 3)
        ])
        
        assertNoMatches(with: hiho, on: "h")
        assertMatches(with: hiho, on: "ho", areLike: [
            .match(contents: "ho", startOffset: 0, endOffset: 2)
        ])
        assertMatches(with: hiho, on: "hoo", areLike: [
            .match(contents: "hoo", startOffset: 0, endOffset: 3)
        ])
        assertMatches(with: hiho, on: "hooo", areLike: [
            .match(contents: "hooo", startOffset: 0, endOffset: 4)
        ])
        assertMatches(with: hiho, on: "hio", areLike: [
            .match(contents: "hio", startOffset: 0, endOffset: 3)
        ])
        
        assertMatches(with: hiho, on: "hhi", areLike: [
            .match(contents: "hi", startOffset: 1, endOffset: 3)
        ])
        assertMatches(with: hiho, on: "hihi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2),
            .match(contents: "hi", startOffset: 2, endOffset: 4)
        ])
        assertMatches(with: hiho, on: "hiihi", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3),
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
        assertMatches(with: hiho, on: "hiiihi", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4),
            .match(contents: "hi", startOffset: 4, endOffset: 6)
        ])
        assertMatches(with: hiho, on: "hoihi", areLike: [
            .match(contents: "hoi", startOffset: 0, endOffset: 3),
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
        
        assertMatches(with: hiho, on: "hho", areLike: [
            .match(contents: "ho", startOffset: 1, endOffset: 3)
        ])
        assertMatches(with: hiho, on: "hoho", areLike: [
            .match(contents: "ho", startOffset: 0, endOffset: 2),
            .match(contents: "ho", startOffset: 2, endOffset: 4)
        ])
        assertMatches(with: hiho, on: "hoohi", areLike: [
            .match(contents: "hoo", startOffset: 0, endOffset: 3),
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
        assertMatches(with: hiho, on: "hoooho", areLike: [
            .match(contents: "hooo", startOffset: 0, endOffset: 4),
            .match(contents: "ho", startOffset: 4, endOffset: 6)
        ])
        assertMatches(with: hiho, on: "hoioho", areLike: [
            .match(contents: "hoio", startOffset: 0, endOffset: 4),
            .match(contents: "ho", startOffset: 4, endOffset: 6)
            ])
        assertMatches(with: hiho, on: "hioho", areLike: [
            .match(contents: "hio", startOffset: 0, endOffset: 3),
            .match(contents: "ho", startOffset: 3, endOffset: 5)
        ])
        
        // Tests with backtracking
        let hi0i = String.pattern("h"/ + ("i"/)* + "i"/)
        
        assertNoMatches(with: hi0i, on: "h")
        assertMatches(with: hi0i, on: "hi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2)
        ])
        assertMatches(with: hi0i, on: "hii", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3)
        ])
        assertMatches(with: hi0i, on: "hiii", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4)
        ])
        assertNoMatches(with: hi0i, on: "hoi")
        
        assertMatches(with: hi0i, on: "hhi", areLike: [
            .match(contents: "hi", startOffset: 1, endOffset: 3)
        ])
        assertMatches(with: hi0i, on: "hihi", areLike: [
            .match(contents: "hi", startOffset: 0, endOffset: 2),
            .match(contents: "hi", startOffset: 2, endOffset: 4)
        ])
        assertMatches(with: hi0i, on: "hiihi", areLike: [
            .match(contents: "hii", startOffset: 0, endOffset: 3),
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
        assertMatches(with: hi0i, on: "hiiihi", areLike: [
            .match(contents: "hiii", startOffset: 0, endOffset: 4),
            .match(contents: "hi", startOffset: 4, endOffset: 6)
        ])
        assertMatches(with: hi0i, on: "hoihi", areLike: [
            .match(contents: "hi", startOffset: 3, endOffset: 5)
        ])
    }
    
    func testCommonPatterns() {
        // Matches paired double-quotes, allowing backslash escapes.
        let unquotedChars = String.pattern(!any("\"", "\\"))*   // FIXME: This should be a possessive matcher
        let escapedChar = String.pattern("\\"/ + any())
        let quotedStringPattern = "\""/ + unquotedChars + (escapedChar + unquotedChars)* + "\""/
        
        assertMatches(with: quotedStringPattern, on: "let y = \"Hello, world!\"", areLike: [
            .match(contents: "\"Hello, world!\"", startOffset: 8, endOffset: 23)
        ])
        assertMatches(with: quotedStringPattern, on: "let y = \"Hello\\\" world!\"", areLike: [
            .match(contents: "\"Hello\\\" world!\"", startOffset: 8, endOffset: 24)
        ])
        assertMatches(with: quotedStringPattern, on: "let y = \"Hello\\\\ world!\"", areLike: [
            .match(contents: "\"Hello\\\\ world!\"", startOffset: 8, endOffset: 24)
        ])
        assertMatches(with: quotedStringPattern, on: "let y = \"Hello\\\\\" world!\"", areLike: [
            .match(contents: "\"Hello\\\\\"", startOffset: 8, endOffset: 17)
        ])
        assertMatches(with: quotedStringPattern, on: "let y = \"Hello, world!\"; let z = \"Goodnight, moon!\"", areLike: [
            .match(contents: "\"Hello, world!\"", startOffset: 8, endOffset: 23),
            .match(contents: "\"Goodnight, moon!\"", startOffset: 33, endOffset: 51)
        ])
        assertNoMatches(with: quotedStringPattern, on: "let y = \"Hello, world!")
    }
}

func assertMatches<P: PatternProtocol, C>(with pattern: P, on target: P.Matcher.Target, areLike descriptions: [MatchDescriptor<C, P.Matcher.Target>], file: StaticString = #file, line: UInt = #line) {
    let matchesWithNil = target.matches(with: pattern).map(Optional.init) + [nil]
    let descriptionsWithEnd = descriptions + [.end]
    
    for (match, description) in zip(matchesWithNil, descriptionsWithEnd) {
        description.assert(describes: match, on: target, file: file, line: line)
    }
}

func assertNoMatches<P: PatternProtocol>(with pattern: P, on target: P.Matcher.Target, file: StaticString = #file, line: UInt = #line) {
    assertMatches(with: pattern, on: target, areLike: [] as [MatchDescriptor<P.Matcher.Target, P.Matcher.Target>], file: file, line: line)
}

enum MatchDescriptor<C: Collection, T: Collection> where C.Element: Equatable, T.Element == C.Element, T.SubSequence: Collection {
    case match(contents: C, startOffset: T.IndexDistance, endOffset: T.IndexDistance)
    case end 
    
    func assert(describes match: PatternMatch<T>?, on target: T, file: StaticString, line: UInt) {
        func index(for offset: T.IndexDistance) -> T.Index? {
            return target.index(target.startIndex, offsetBy: offset, limitedBy: target.endIndex)
        }
        
        switch (self, match) {
        case (.match, nil):
            XCTFail("Missing matches", file: file, line: line)
        case (.end, let match?):
            XCTFail("Too many matches (\(match.contents) at \(match.range))", file: file, line: line)
        case (.end, nil):
            break
            
        case let (.match(contents, startOffset, endOffset), match?):
            let startIndex = index(for: startOffset)
            let endIndex = index(for: endOffset)
            XCTAssertEqual(startIndex, match.range.lowerBound, "Matched at correct start index", file: file, line: line)
            XCTAssertEqual(endIndex, match.range.upperBound, "Matched at correct end index", file: file, line: line)
            XCTAssertTrue(match.contents.elementsEqual(contents), "Matched correct contents (\(match.contents) == \(contents)", file: file, line: line)
        }
    }
}
