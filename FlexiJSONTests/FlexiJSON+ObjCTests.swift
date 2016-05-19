//
//  FlexiJSON+ObjCTests.swift
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

class FlexiJSON_ObjCTests: XCTestCase {
    
    // MARK: - init data

    func test_init_data_shouldSetError_whenInvalidData() {
        let json = FlexiJSON(data: NSData())
        XCTAssertEqual(json.error, "Initialised FlexiJSON with invalid data.")
    }

    func test_init_data_shouldSetDictionary() {
        let data = "{ \"simple\": \"json\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        let json = FlexiJSON(data: data)
        XCTAssertEqual(json, FlexiJSON(dictionary: ["simple": "json"]))
    }

    func test_init_data_shouldSetArray() {
        let data = "[ { \"simple\": \"json\"} ]".dataUsingEncoding(NSUTF8StringEncoding)!
        let json = FlexiJSON(data: data)
        XCTAssertEqual(json, FlexiJSON(array: [["simple": "json"]]))
    }

    func test_init_data_shouldSetFragment() {
        let data = "\"string\"".dataUsingEncoding(NSUTF8StringEncoding)!
        let json = FlexiJSON(data: data)
        XCTAssertEqual(json, FlexiJSON(string: "string"))
    }

    // MARK: - init string

    func test_init_string_shouldSetError_whenInvalidString() {
        let string = "not json"
        let json = FlexiJSON(jsonString: string)
        XCTAssertEqual(json, FlexiJSON(error: "Initialised FlexiJSON with invalid string."))
    }

    func test_init_string_shouldParseJSON_fromValidString() {
        let string = "{ \"valid\": \"json\" }"
        let json = FlexiJSON(jsonString: string)
        XCTAssertEqual(json, FlexiJSON(dictionary: ["valid": "json"]))
    }

    func test_init_string_shouldParseJSONFragment() {
        let string = "\"fragment\""
        let json = FlexiJSON(jsonString: string)
        XCTAssertEqual(json, FlexiJSON(string: "fragment"))
    }

    // MARK: - data

    func test_data_shouldNotConvertNonJSONObject() {
        XCTAssertNil(FlexiJSON(string: "string").data)
    }

    func test_data_shouldConvertDictionary() {
        let dictionary = ["key": "value"]
        let expected = try? NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
        XCTAssertEqual(FlexiJSON(dictionary: dictionary).data, expected)
    }

    func test_data_shouldConvertArray() {
        let array = [["key": "value"]]
        let expected = try? NSJSONSerialization.dataWithJSONObject(array, options: [])
        XCTAssertEqual(FlexiJSON(array: array).data, expected)
    }

    // MARK: - jsonString

    func test_jsonString_shouldNotConvertNonJSONObject() {
        XCTAssertNil(FlexiJSON(string: "string").jsonString)
    }

    func test_jsonString_shouldConvertDictionary() {
        let dictionary = ["key": "value"]
        let expected = "{\"key\":\"value\"}"
        XCTAssertEqual(FlexiJSON(dictionary: dictionary).jsonString, expected)
    }

    func test_jsonString_shouldConvertArray() {
        let array = [["key": "value"]]
        let expected = "[{\"key\":\"value\"}]"
        XCTAssertEqual(FlexiJSON(array: array).jsonString, expected)
    }
}
