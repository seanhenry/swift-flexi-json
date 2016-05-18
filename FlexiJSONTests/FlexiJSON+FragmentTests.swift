//
//  FlexiJSON+FragmentTests.swift
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

class FlexiJSON_Fragment: XCTestCase {

    typealias Fragment = FlexiJSON.Fragment

    func test_equals_shouldBeTrue_whenStringFragmentsMatch() {
        XCTAssertEqual(Fragment.String("hello"), Fragment.String("hello"))
    }

    func test_equals_shouldBeFalse_whenStringFragmentsDoNotMatch() {
        XCTAssertNotEqual(Fragment.String("hello"), Fragment.String("hi"))
    }

    func test_equals_shouldBeFalse_whenDictionaryFragmentsDoNotMatch() {
        let dict = ["key": Fragment.String("hi")]
        let dict2 = ["key": Fragment.String("hello")]
        XCTAssertNotEqual(Fragment.Dictionary(dict), Fragment.Dictionary(dict2))
    }

    func test_equals_shouldBeFalse_whenDictionaryLengthsAreDifferent() {
        let dict = ["key": Fragment.String("hello")]
        let dict2 = ["key": Fragment.String("hello"), "key2" : Fragment.String("some")]
        XCTAssertNotEqual(Fragment.Dictionary(dict), Fragment.Dictionary(dict2))
    }

    func test_equals_shouldBeTrue_whenDictionariesAreEqual() {
        XCTAssertEqual(Fragment.from(allTypesDictionary()), Fragment.from(allTypesDictionary()))
    }

    func test_equals_shouldBeFalse_whenDoublesAreDifferent() {
        XCTAssertNotEqual(Fragment.Double(123.456), Fragment.Double(987.654))
    }

    func test_equals_shouldBeTrue_whenDoublesAreEqual() {
        XCTAssertEqual(Fragment.Double(123.0), Fragment.Double(123.0))
    }

    func test_equals_shouldBeFalse_whenBoolsAreDifferent() {
        XCTAssertNotEqual(Fragment.Bool(true), Fragment.Bool(false))
    }

    func test_equals_shouldBeTrue_whenBoolsAreEqual() {
        XCTAssertEqual(Fragment.Bool(true), Fragment.Bool(true))
    }

    func test_equals_shouldBeFalse_whenArraysAreDifferent() {
        let array1 = [Fragment.String("hello"), Fragment.Double(123), Fragment.Bool(true)]
        let array2 = [Fragment.String("hello")]
        XCTAssertNotEqual(Fragment.Array(array1), Fragment.Array(array2))
    }

    func test_equals_shouldBeTrue_whenArraysAreEqual() {
        let array = [Fragment.String("hello"), Fragment.Double(123), Fragment.Bool(true)]
        XCTAssertEqual(Fragment.Array(array), Fragment.Array(array))
    }

    func test_equals_shouldBeFalse_whenFragmentsAreDifferentTypes() {
        XCTAssertNotEqual(Fragment.Bool(false), Fragment.String("false"))
    }

    func test_equals_shouldBeTrue_whenBothFragmentsAreNull() {
        XCTAssertEqual(Fragment.Null, Fragment.Null)
    }

    // MARK: - from: AnyObject

    func test_from_shouldCreateFromString() {
        XCTAssertEqual(Fragment.from("string"), Fragment.String("string"))
    }

    func test_from_shouldCreateFromInt() {
        XCTAssertEqual(Fragment.from(123), Fragment.Double(123))
    }

    func test_from_shouldCreateFromDouble() {
        XCTAssertEqual(Fragment.from(123.456), Fragment.Double(123.456))
    }

    func test_from_shouldCreateFromBool() {
        XCTAssertEqual(Fragment.from(true), Fragment.Bool(true))
    }

    func test_from_shouldCreateFromNull() {
        XCTAssertNotNil(Fragment.from(NSNull()))
    }

    // MARK: - from: JSONDictionary

    func test_from_shouldCreateFromDictionary() {
        let fromDictionary = Fragment.from(allTypesDictionary())
        let dictionary = Fragment.Dictionary(allTypesDictionaryFragment())
        XCTAssertEqual(fromDictionary, dictionary)
    }

    func test_from_shouldCreateFromNestedDictionary() {
        let fromDictionary = Fragment.from(nestedDictionary())
        let dictionary = Fragment.Dictionary(nestedDictionaryFragment())
        XCTAssertEqual(fromDictionary, dictionary)
    }

    // MARK: - from: JSONArray

    func test_from_shouldCreateFromArray() {
        let fromArray = Fragment.from(allTypesArray())
        let array = Fragment.Array(allTypesArrayFragment())
        XCTAssertEqual(fromArray, array)
    }

    func test_from_shouldCreateNestedArray() {
        let fromArray = Fragment.from(nestedArray())
        let array = Fragment.Array(nestedArrayFragment())
        XCTAssertEqual(fromArray, array)
    }

    // MARK: - cast

    func test_cast_shouldConvertString() {
        XCTAssertEqual(Fragment.String("some").cast(String.self), "some")
    }

    func test_cast_shouldConvertDouble() {
        XCTAssertEqual(Fragment.Double(123).cast(Double.self), 123)
    }

    func test_cast_shouldConvertBool() {
        XCTAssertEqual(Fragment.Bool(true).cast(Bool.self), true)
    }

    func test_cast_shouldConvertDictionary() {
        let dictionary = Fragment.Dictionary(allTypesDictionaryFragment()).cast(JSONDictionary.self)
        XCTAssertEqual(dictionary?["string"] as? String, "string")
        XCTAssertEqual(dictionary?["int"] as? Int, 123)
        XCTAssertEqual(dictionary?["double"] as? Double, 123.456)
        XCTAssertEqual(dictionary?["bool"] as? Bool, true)
        XCTAssertEqual(dictionary?.count, 4)
    }

    func test_cast_shouldConvertArray() {
        let array = Fragment.Array(allTypesArrayFragment()).cast(JSONArray.self)
        XCTAssertEqual(array?[0] as? String, "string")
        XCTAssertEqual(array?[1] as? Int, 123)
        XCTAssertEqual(array?[1] as? Double, 123.0)
        XCTAssertEqual(array?[1] as? Bool, true)
        XCTAssertEqual(array?.count, 4)
    }

    func test_case_shouldConvertNull() {
        XCTAssertNotNil(Fragment.Null.cast(NSNull.self))
    }

    // MARK: - description

    func test_description_whenString() {
        let description = "string"
        let fragment = Fragment.String(description)
        XCTAssertEqual(fragment.description, description)
    }

    func test_description_whenDictionary() {
        let dictionary = ["key": Fragment.String("value")]
        let description = dictionary.description
        XCTAssertEqual(Fragment.Dictionary(dictionary).description, description)
    }

    func test_description_whenArray() {
        let array = [Fragment.String("string"), Fragment.Double(123)]
        let description = array.description
        XCTAssertEqual(Fragment.Array(array).description, description)
    }

    func test_description_whenDouble() {
        let double = 1.99
        let description = double.description
        XCTAssertEqual(Fragment.Double(double).description, description)
    }
    

    func test_description_whenBool() {
        let bool = true
        let description = bool.description
        XCTAssertEqual(Fragment.Bool(bool).description, description)
    }

    func test_description_whenNull() {
        let description = "null"
        XCTAssertEqual(Fragment.Null.description, "null")
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

    func allTypesDictionaryFragment() -> [String : Fragment] {
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

    func nestedDictionaryFragment() -> [String : Fragment] {
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

    func allTypesArrayFragment() -> [Fragment] {
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

    func nestedArrayFragment() -> [Fragment] {
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
