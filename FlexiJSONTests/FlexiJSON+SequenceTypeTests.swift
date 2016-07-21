//
//  FlexiJSON+SequenceTypeTests.swift
//
//  Copyright © 2016 Sean Henry. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import FlexiJSON

class FlexiJSON_SequenceTypeTests: XCTestCase {

    func test_generate_shouldHaveZeroCount_whenNotArrayOrDictionary() {
        let json = FlexiJSON(bool: false)
        XCTAssertEqual(countIterations(json: json), 0)
    }

    func test_generate_shouldHaveZeroCount_whenEmptyArray() {
        let json = FlexiJSON(array: [])
        XCTAssertEqual(countIterations(json: json), 0)
    }

    func test_generate_shouldHaveSameCount_asArray() {
        let json = FlexiJSON(array: [1, 2, 3])
        XCTAssertEqual(countIterations(json: json), 3)
    }

    func test_generate_shouldGenerateArrayElements() {
        let json = FlexiJSON(array: [1, 2, 3])
        var i: Int64 = 1
        for fragment in json {
            XCTAssertEqual(fragment, FlexiJSON(int: i))
            i += 1
        }
    }

    func test_generate_shouldHaveZeroCount_whenEmptyDictionary() {
        let json = FlexiJSON(dictionary: [:])
        XCTAssertEqual(countIterations(json: json), 0)
    }

    func test_generate_shouldHaveSameCount_asDictionary() {
        let json = FlexiJSON(dictionary: ["1":1, "2":2, "3":3])
        XCTAssertEqual(countIterations(json: json), 3)
    }

    func test_generate_shouldGenerateDictionaryValues() {
        let json = FlexiJSON(dictionary: ["1":1, "2":2, "3":3])
        var expected: [FlexiJSON] = [["1":1], ["2":2], ["3":3]]
        for fragment in json {
            if let i = expected.indexOf(fragment) {
                expected.removeAtIndex(i)
            }
        }
        XCTAssert(expected.isEmpty)
    }

    // MARK: - Helpers

    func countIterations(json json: FlexiJSON) -> Int {
        var count = 0
        for _ in json {
            count += 1
        }
        return count
    }
}
