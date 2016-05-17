//
//  FlexiJSONTests.swift
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

class FlexiJSONTests: XCTestCase {

    var dictionary: JSONDictionary!
    var json: FlexiJSON!
    let errorJSON = FlexiJSON(error: "error")

    override func setUp() {
        super.setUp()
        dictionary = [
            "key": "value",
            "key2": "value2",
            "array": [
                "string"
            ]
        ]
        json = FlexiJSON(dictionary: dictionary)
    }

    // MARK: - subscript key get

    func test_subscript_shouldSetError() {
        XCTAssertEqual(json["nonexistant"].error, "Key 'nonexistant' was not found.")
    }

    // MARK: - subscript key set

    func test_subscript_shouldReplaceValue() {
        json!["key"] = "success"
        json!["key"] = FlexiJSON(string: "success")
        XCTAssertEqual(json["key"].string, "success")
    }

    func test_subscript_shouldReplaceDeepValue() {
        let dictionary = ["1": ["2": ["3": "value"]]]
        json = FlexiJSON(dictionary: dictionary)
        json!["1"]["2"]["3"] = FlexiJSON(string: "success")
        XCTAssertEqual(json["1"]["2"]["3"].string, "success")
    }

    func test_subscript_shouldReplaceValueWithDifferentValue() {
        let dictionary = ["new": "dictionary"]
        json!["key"] = FlexiJSON(dictionary: dictionary)
        XCTAssertEqual(json["key"], FlexiJSON(dictionary: dictionary))
    }

    func test_subscript_shouldSetError_whenGivenJSONWithError() {
        json!["key"] = errorJSON
        XCTAssertEqual(json.error, errorJSON.error)
    }

    // MARK: - subscript index get

    func test_subscript_index_shouldSetError_whenNotAnArray() {
        XCTAssertEqual(json[0].error, "Attempted to access a nonexistant array.")
    }

    func test_subscript_index_shouldSetError_whenIndexOutOfBounds() {
        let json = FlexiJSON(array: ["some"])
        XCTAssertEqual(json[1].error, "Index '1' is out of bounds.")
    }

    // MARK: - subscript index set

    func test_subscript_index_shouldReplaceValue() {
        json!["array"][0] = FlexiJSON(int: 123)
        XCTAssertEqual(json["array"][0].int, 123)
    }

    func test_subscript_index_shouldReplaceDeepValue() {
        let dictionary = ["1": ["2": ["3": ["value", 123]]]]
        var json = FlexiJSON(dictionary: dictionary)
        json["1"]["2"]["3"][1] = FlexiJSON(bool: true)
        XCTAssertEqual(json["1"]["2"]["3"][1].bool, true)
    }

    func test_subscript_index_shouldSetError_whenGivenJSONWithError() {
        json!["array"][0] = errorJSON
        XCTAssertEqual(json.error, errorJSON.error)
    }

    // MARK: - error

    func test_error_isNil() {
        XCTAssertNil(json.error)
    }

    func test_error_shouldReturnError() {
        let json = FlexiJSON(error: "error")
        XCTAssertEqual(json.error, "error")
    }

    // MARK: - string

    func test_string_isNil() {
        XCTAssertNil(json.string)
    }

    func test_string_shouldReturnString() {
        XCTAssertEqual(json["key"].string, "value")
        XCTAssertEqual(json["key2"].string, "value2")
    }

    func test_string_shouldReturnDeepString() {
        let dictionary = ["1": ["2": ["3": "value"]]]
        json = FlexiJSON(dictionary: dictionary)
        XCTAssertEqual(json["1"]["2"]["3"].string, "value")
    }

    func test_string_shouldReturnArrayString() {
        let array = ["value"]
        json = FlexiJSON(array: array)
        XCTAssertEqual(json[0].string, "value")
    }

    // MARK: - int

    func test_int_isNil() {
        XCTAssertNil(json.int)
    }

    func test_int_shouldReturnInt() {
        let json = FlexiJSON(int: 123)
        XCTAssertEqual(json.int, 123)
    }

    func test_int_shouldReturnMaxIntPossible() {
        var max = (Int64.max >> 10)
        for _ in 0...10 {
            let json = FlexiJSON(int: max)
            XCTAssertEqual(json.int, max)
            max -= 1
        }
    }

    func test_int_shouldReturnMinIntPossible() {
        var min = (Int64.min >> 10)
        for _ in 0...10 {
            let json = FlexiJSON(int: min)
            XCTAssertEqual(json.int, min)
            min += 1
        }
    }

    // MARK: - double

    func test_double_isNil() {
        XCTAssertNil(json.double)
    }

    func test_double_shouldReturnDouble() {
        let json = FlexiJSON(double: 123.456)
        XCTAssertEqual(json.double, 123.456)
    }

    // MARK: - bool

    func test_bool_isNil() {
        XCTAssertNil(json.bool)
    }

    func test_bool_shouldReturnBool() {
        let json = FlexiJSON(bool: true)
        XCTAssertEqual(json.bool, true)
    }

    // MARK: - null

    func test_null_isNil() {
        XCTAssertNil(json.null)
    }

    func test_null_shouldReturnNull() {
        let json = FlexiJSON(null: JSONNull())
        XCTAssertNotNil(json.null)
    }

    // MARK: - dictionary

    func test_dictionary_shouldBeNil() {
        let json = FlexiJSON(array: [])
        XCTAssertNil(json.dictionary)
    }

    func test_dictionary_isNotNil() {
        XCTAssertEqual(json.dictionary?["key"] as? String, "value")
    }

    // MARK: - array

    func test_array_shouldBeNil() {
        XCTAssertNil(json.array)
    }

    func test_array_shouldReturnArray() {
        let json = FlexiJSON(array: ["hello"])
        XCTAssertEqual(json.array?[0] as? String, "hello")
    }

    // MARK: - ==

    func test_equals_shouldBeTrue_whenContainsEqualValues() {
        XCTAssertEqual(json, json)
    }

    func test_equals_shouldBeFalse_whenContainsInequalValues() {
        XCTAssertNotEqual(json, FlexiJSON(dictionary: [:]))
    }

    func test_equals_shouldBeFalse_whenContainsInequalErrors() {
        let json = FlexiJSON(error: "")
        XCTAssertNotEqual(json, errorJSON)
    }

    func test_equals_shouldBeTrue_whenContainsEqualsErrors() {
        XCTAssertEqual(errorJSON, errorJSON)
    }

    func test_equals_shouldBeFalse_whenComparingErrorAndValue() {
        XCTAssertNotEqual(json, errorJSON)
    }
}
