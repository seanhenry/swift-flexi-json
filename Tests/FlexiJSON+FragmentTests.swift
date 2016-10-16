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

    // MARK: ==

    func test_equals_shouldBeTrue_whenStringFragmentsMatch() {
        XCTAssertEqual(Fragment.string("hello"), Fragment.string("hello"))
    }

    func test_equals_shouldBeFalse_whenStringFragmentsDoNotMatch() {
        XCTAssertNotEqual(Fragment.string("hello"), Fragment.string("hi"))
    }

    func test_equals_shouldBeFalse_whenDictionaryFragmentsDoNotMatch() {
        let dict = ["key": Fragment.string("hi")]
        let dict2 = ["key": Fragment.string("hello")]
        XCTAssertNotEqual(Fragment.dictionary(dict), Fragment.dictionary(dict2))
    }

    func test_equals_shouldBeFalse_whenDictionaryLengthsAreDifferent() {
        let dict = ["key": Fragment.string("hello")]
        let dict2 = ["key": Fragment.string("hello"), "key2" : Fragment.string("some")]
        XCTAssertNotEqual(Fragment.dictionary(dict), Fragment.dictionary(dict2))
    }

    func test_equals_shouldBeTrue_whenDictionariesAreEqual() {
        XCTAssertEqual(Fragment.from(allTypesDictionary()), Fragment.from(allTypesDictionary()))
    }

    func test_equals_shouldBeFalse_whenDoublesAreDifferent() {
        XCTAssertNotEqual(Fragment.double(123.456), Fragment.double(987.654))
    }

    func test_equals_shouldBeTrue_whenDoublesAreEqual() {
        XCTAssertEqual(Fragment.double(123.0), Fragment.double(123.0))
    }

    func test_equals_shouldBeFalse_whenBoolsAreDifferent() {
        XCTAssertNotEqual(Fragment.bool(true), Fragment.bool(false))
    }

    func test_equals_shouldBeTrue_whenBoolsAreEqual() {
        XCTAssertEqual(Fragment.bool(true), Fragment.bool(true))
    }

    func test_equals_shouldBeFalse_whenArraysAreDifferent() {
        let array1 = [Fragment.string("hello"), Fragment.double(123), Fragment.bool(true)]
        let array2 = [Fragment.string("hello")]
        XCTAssertNotEqual(Fragment.array(array1), Fragment.array(array2))
    }

    func test_equals_shouldBeTrue_whenArraysAreEqual() {
        let array = [Fragment.string("hello"), Fragment.double(123), Fragment.bool(true)]
        XCTAssertEqual(Fragment.array(array), Fragment.array(array))
    }

    func test_equals_shouldBeFalse_whenFragmentsAreDifferentTypes() {
        XCTAssertNotEqual(Fragment.bool(false), Fragment.string("false"))
    }

    func test_equals_shouldBeTrue_whenBothFragmentsAreNull() {
        XCTAssertEqual(Fragment.null, Fragment.null)
    }

    // MARK: - from: Any

    func test_from_shouldCreateFromString() {
        XCTAssertEqual(Fragment.from("string"), Fragment.string("string"))
    }

    func test_from_shouldCreateFromInt() {
        XCTAssertEqual(Fragment.from(123), Fragment.double(123))
    }

    func test_from_shouldCreateFromDouble() {
        XCTAssertEqual(Fragment.from(123.456), Fragment.double(123.456))
    }

    func test_from_shouldCreateFromBool() {
        XCTAssertEqual(Fragment.from(true), Fragment.bool(true))
    }

    func test_from_shouldCreateFromNull() {
        XCTAssertNotNil(Fragment.from(NSNull()))
    }

    func test_from_shouldBeNil_whenNotKnownJSONType() {
        XCTAssertNil(Fragment.from(NonJSON()))
    }

    // MARK: - from: JSONDictionary

    func test_from_shouldCreateFromDictionary() {
        let fromDictionary = Fragment.from(allTypesDictionary())
        let dictionary = Fragment.dictionary(allTypesDictionaryFragment())
        XCTAssertEqual(fromDictionary, dictionary)
    }

    func test_from_shouldCreateFromNestedDictionary() {
        let fromDictionary = Fragment.from(nestedDictionary())
        let dictionary = Fragment.dictionary(nestedDictionaryFragment())
        XCTAssertEqual(fromDictionary, dictionary)
    }

    func test_from_shouldBeNil_whenDictionaryContainingNonJSONType() {
        XCTAssertNil(Fragment.from(["key": NonJSON()]))
    }

    // MARK: - from: JSONArray

    func test_from_shouldCreateFromArray() {
        let fromArray = Fragment.from(allTypesArray())
        let array = Fragment.array(allTypesArrayFragment())
        XCTAssertEqual(fromArray, array)
    }

    func test_from_shouldCreateNestedArray() {
        let fromArray = Fragment.from(nestedArray())
        let array = Fragment.array(nestedArrayFragment())
        XCTAssertEqual(fromArray, array)
    }

    func test_from_shouldBeNil_whenArrayContainsNonJSONType() {
        XCTAssertNil(Fragment.from([NonJSON()]))
    }

    // MARK: - cast

    func test_cast_shouldConvertString() {
        XCTAssertEqual(Fragment.string("some").cast(String.self), "some")
    }

    func test_cast_shouldConvertDouble() {
        XCTAssertEqual(Fragment.double(123).cast(Double.self), 123)
    }

    func test_cast_shouldConvertBool() {
        XCTAssertEqual(Fragment.bool(true).cast(Bool.self), true)
    }

    func test_cast_shouldConvertDictionary() {
        let dictionary = Fragment.dictionary(allTypesDictionaryFragment()).cast(JSONDictionary.self)
        XCTAssertEqual(dictionary?["string"] as? String, "string")
        XCTAssertEqual(dictionary?["int"] as? NSNumber, 123)
        XCTAssertEqual(dictionary?["double"] as? Double, 123.456)
        XCTAssertEqual(dictionary?["bool"] as? Bool, true)
        XCTAssertEqual(dictionary?.count, 4)
    }

    func test_cast_shouldConvertArray() {
        let array = Fragment.array(allTypesArrayFragment()).cast(JSONArray.self)
        XCTAssertEqual(array?[0] as? String, "string")
        XCTAssertEqual(array?[1] as? NSNumber, 123)
        XCTAssertEqual(array?[2] as? Double, 123.456)
        XCTAssertEqual(array?[3] as? Bool, true)
        XCTAssertEqual(array?.count, 4)
    }

    func test_case_shouldConvertNull() {
        XCTAssertNotNil(Fragment.null.cast(NSNull.self))
    }

    // MARK: - description

    func test_description_whenString() {
        let description = "string"
        let fragment = Fragment.string(description)
        XCTAssertEqual(fragment.description, description)
    }

    func test_description_whenDictionary() {
        let dictionary = ["key": Fragment.string("value")]
        let description = dictionary.description
        XCTAssertEqual(Fragment.dictionary(dictionary).description, description)
    }

    func test_description_whenArray() {
        let array = [Fragment.string("string"), Fragment.double(123)]
        let description = array.description
        XCTAssertEqual(Fragment.array(array).description, description)
    }

    func test_description_whenDouble() {
        let double = 1.99
        let description = double.description
        XCTAssertEqual(Fragment.double(double).description, description)
    }
    

    func test_description_whenBool() {
        let bool = true
        let description = bool.description
        XCTAssertEqual(Fragment.bool(bool).description, description)
    }

    func test_description_whenNull() {
        XCTAssertEqual(Fragment.null.description, "null")
    }

    // MARK: - Helpers

    func allTypesDictionary() -> JSONDictionary {
        return [
            "string": "string",
            "int": 123,
            "double": 123.456,
            "bool": true
        ]
    }

    func allTypesDictionaryFragment() -> [String : Fragment] {
        return [
            "string": .string("string"),
            "int": .double(123),
            "double": .double(123.456),
            "bool": .bool(true)
        ]
    }

    func nestedDictionary() -> JSONDictionary {
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
            "1": .dictionary([
                "2": .dictionary([
                    "3": .string("value")
                    ])
                ])
        ]
    }

    func allTypesArray() -> [Any] {
        return [
            "string",
            123,
            123.456,
            true
        ]
    }

    func allTypesArrayFragment() -> [Fragment] {
        return [
            .string("string"),
            .double(123),
            .double(123.456),
            .bool(true)
        ]
    }

    func nestedArray() -> JSONArray {
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
            .array([
                .string("string"),
                .double(123),
                .double(123.456),
                .bool(true)
                ])
        ]
    }

    class NonJSON {}
}
