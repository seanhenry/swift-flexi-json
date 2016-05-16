//
//  FlexiJSON+ValueTests.swift
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

class FlexiJSON_Value: XCTestCase {

    typealias Value = FlexiJSON.Value

    func test_equals_shouldBeTrue_whenStringValuesMatch() {
        XCTAssertEqual(Value.String("hello"), Value.String("hello"))
    }

    func test_equals_shouldBeFalse_whenStringValuesDoNotMatch() {
        XCTAssertNotEqual(Value.String("hello"), Value.String("hi"))
    }

    func test_equals_shouldBeFalse_whenDictionaryValuesDoNotMatch() {
        let dict = ["key": Value.String("hi")]
        let dict2 = ["key": Value.String("hello")]
        XCTAssertNotEqual(Value.Dictionary(dict), Value.Dictionary(dict2))
    }

    func test_equals_shouldBeFalse_whenDictionaryLengthsAreDifferent() {
        let dict = ["key": Value.String("hello")]
        let dict2 = ["key": Value.String("hello"), "key2" : Value.String("some")]
        XCTAssertNotEqual(Value.Dictionary(dict), Value.Dictionary(dict2))
    }

    func test_equals_shouldBeTrue_whenDictionariesAreEqual() {
        XCTAssertEqual(Value.from(allTypesDictionary()), Value.from(allTypesDictionary()))
    }

    func test_equals_shouldBeFalse_whenDoublesAreDifferent() {
        XCTAssertNotEqual(Value.Double(123.456), Value.Double(987.654))
    }

    func test_equals_shouldBeTrue_whenDoublesAreEqual() {
        XCTAssertEqual(Value.Double(123.0), Value.Double(123.0))
    }

    func test_equals_shouldBeFalse_whenBoolsAreDifferent() {
        XCTAssertNotEqual(Value.Bool(true), Value.Bool(false))
    }

    func test_equals_shouldBeTrue_whenBoolsAreEqual() {
        XCTAssertEqual(Value.Bool(true), Value.Bool(true))
    }

    func test_equals_shouldBeFalse_whenArraysAreDifferent() {
        let array1 = [Value.String("hello"), Value.Double(123), Value.Bool(true)]
        let array2 = [Value.String("hello")]
        XCTAssertNotEqual(Value.Array(array1), Value.Array(array2))
    }

    func test_equals_shouldBeTrue_whenArraysAreEqual() {
        let array = [Value.String("hello"), Value.Double(123), Value.Bool(true)]
        XCTAssertEqual(Value.Array(array), Value.Array(array))
    }

    func test_equals_shouldBeFalse_whenValuesAreDifferentTypes() {
        XCTAssertNotEqual(Value.Bool(false), Value.String("false"))
    }

    func test_equals_shouldBeTrue_whenBothValuesAreNull() {
        XCTAssertEqual(Value.Null, Value.Null)
    }

    // MARK: - from: AnyObject

    func test_from_shouldCreateFromString() {
        XCTAssertEqual(Value.from("string"), Value.String("string"))
    }

    func test_from_shouldCreateFromInt() {
        XCTAssertEqual(Value.from(123), Value.Double(123))
    }

    func test_from_shouldCreateFromDouble() {
        XCTAssertEqual(Value.from(123.456), Value.Double(123.456))
    }

    func test_from_shouldCreateFromBool() {
        XCTAssertEqual(Value.from(true), Value.Bool(true))
    }

    func test_from_shouldCreateFromNull() {
        XCTAssertNotNil(Value.from(NSNull()))
    }

    // MARK: - from: JSONDictionary

    func test_from_shouldCreateFromDictionary() {
        let fromDictionary = Value.from(allTypesDictionary())
        let dictionary = Value.Dictionary(allTypesDictionaryValue())
        XCTAssertEqual(fromDictionary, dictionary)
    }

    func test_from_shouldCreateFromNestedDictionary() {
        let fromDictionary = Value.from(nestedDictionary())
        let dictionary = Value.Dictionary(nestedDictionaryValue())
        XCTAssertEqual(fromDictionary, dictionary)
    }

    // MARK: - from: JSONArray

    func test_from_shouldCreateFromArray() {
        let fromArray = Value.from(allTypesArray())
        let array = Value.Array(allTypesArrayValue())
        XCTAssertEqual(fromArray, array)
    }

    func test_from_shouldCreateNestedArray() {
        let fromArray = Value.from(nestedArray())
        let array = Value.Array(nestedArrayValue())
        XCTAssertEqual(fromArray, array)
    }

    // MARK: - cast

    func test_cast_shouldConvertString() {
        XCTAssertEqual(Value.String("some").cast(String.self), "some")
    }

    func test_cast_shouldConvertDouble() {
        XCTAssertEqual(Value.Double(123).cast(Double.self), 123)
    }

    func test_cast_shouldConvertBool() {
        XCTAssertEqual(Value.Bool(true).cast(Bool.self), true)
    }

    func test_cast_shouldConvertDictionary() {
        let dictionary = Value.Dictionary(allTypesDictionaryValue()).cast(JSONDictionary.self)
        XCTAssertEqual(dictionary?["string"] as? String, "string")
        XCTAssertEqual(dictionary?["int"] as? Int, 123)
        XCTAssertEqual(dictionary?["double"] as? Double, 123.456)
        XCTAssertEqual(dictionary?["bool"] as? Bool, true)
        XCTAssertEqual(dictionary?.count, 4)
    }

    func test_cast_shouldConvertArray() {
        let array = Value.Array(allTypesArrayValue()).cast(JSONArray.self)
        XCTAssertEqual(array?[0] as? String, "string")
        XCTAssertEqual(array?[1] as? Int, 123)
        XCTAssertEqual(array?[1] as? Double, 123.0)
        XCTAssertEqual(array?[1] as? Bool, true)
        XCTAssertEqual(array?.count, 4)
    }

    func test_case_shouldConvertNull() {
        XCTAssertNotNil(Value.Null.cast(JSONNull.self))
    }

    // MARK: - Helpers

    func allTypesDictionary() -> [String : AnyObject] {
        return [
            "string": "string",
            "int": 123,
            "double": 123.456,
            "bool": true
        ]
    }

    func allTypesDictionaryValue() -> [String : Value] {
        return [
            "string": .String("string"),
            "int": .Double(123),
            "double": .Double(123.456),
            "bool": .Bool(true)
        ]
    }

    func nestedDictionary() -> [String : AnyObject] {
        return [
            "1": [
                "2": [
                    "3": "value"
                ]
            ]
        ]
    }

    func nestedDictionaryValue() -> [String : Value] {
        return [
            "1": .Dictionary([
                "2": .Dictionary([
                    "3": .String("value")
                    ])
                ])
        ]
    }

    func allTypesArray() -> [AnyObject] {
        return [
            "string",
            123,
            123.456,
            true
        ]
    }

    func allTypesArrayValue() -> [Value] {
        return [
            .String("string"),
            .Double(123),
            .Double(123.456),
            .Bool(true)
        ]
    }

    func nestedArray() -> [AnyObject] {
        return [
            [
                "string",
                123,
                123.456,
                true
            ]
        ]
    }

    func nestedArrayValue() -> [Value] {
        return [
            .Array([
                .String("string"),
                .Double(123),
                .Double(123.456),
                .Bool(true)
                ])
        ]
    }
}
