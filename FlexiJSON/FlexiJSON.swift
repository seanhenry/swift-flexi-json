//
//  FlexiJSON.swift
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

import Swift

public typealias JSONDictionary = [String : AnyObject]
public typealias JSONArray = [AnyObject]
public typealias JSONString = String
public typealias JSONInt = Int64
public typealias JSONDouble = Double
public typealias JSONBool = Bool
public typealias JSONNull = ()

public struct FlexiJSON {

    private var either: Either

    public init(dictionary: JSONDictionary) {
        self.init(value: .from(dictionary))
    }

    public init(array: JSONArray) {
        self.init(value: .from(array))
    }

    public init(string: JSONString) {
        self.init(value: .String(string))
    }

    public init(int: JSONInt) {
        self.init(value: .Double(Double(int)))
    }

    public init(double: JSONDouble) {
        self.init(value: .Double(double))
    }

    public init(bool: JSONBool) {
        self.init(value: .Bool(bool))
    }

    public init(null: JSONNull) {
        self.init(value: .Null)
    }

    public init(error: String) {
        either = .Error(error)
    }

    private init(value: Value) {
        either = .Value(value)
    }
}

// MARK: - Either

extension FlexiJSON {

    typealias JSONValue = Value

    private enum Either {
        case Value(JSONValue)
        case Error(String)

        var value: JSONValue? {
            if case .Value(let value) = self {
                return value
            }
            return nil
        }

        var error: String? {
            if case .Error(let error) = self {
                return error
            }
            return nil
        }
    }
}

// MARK: - Subscript
extension FlexiJSON {

    public subscript(key: String) -> FlexiJSON {
        set(newJSON) {
            if let error = newJSON.error {
                either = .Error(error)
                return
            }
            if case .Dictionary(var d)? = either.value,
               let newValue = newJSON.either.value {
                d[key] = newValue
                either = .Value(.Dictionary(d))
            }
        }
        get {
            guard case .Dictionary(let d)? = either.value,
                  let value = d[key] else {
                return FlexiJSON(error: "Key '\(key)' was not found.")
            }
            return FlexiJSON(value: value)
        }
    }

    public subscript(index: Int) -> FlexiJSON {
        set(newJSON) {
            if let error = newJSON.error {
                either = .Error(error)
                return
            }
            if case .Array(var a)? = either.value,
               let newValue = newJSON.either.value {
                a[index] = newValue
                either = .Value(.Array(a))
            }
        }
        get {
            guard case .Array(let a)? = either.value else {
                return FlexiJSON(error: "Attempted to access a nonexistant array.")
            }
            guard index < a.count else {
                return FlexiJSON(error: "Index '\(index)' is out of bounds.")
            }
            return FlexiJSON(value: a[index])
        }
    }
}

// MARK: - Equatable
extension FlexiJSON: Equatable {
}

public func ==(lhs: FlexiJSON, rhs: FlexiJSON) -> Bool {
    switch (lhs.either, rhs.either) {
    case (.Value(let lhsValue), .Value(let rhsValue)):
        return lhsValue == rhsValue
    case (.Error(let lhsError), .Error(let rhsError)):
        return lhsError == rhsError
    default:
        return false
    }
}

// MARK: - Computed properties
extension FlexiJSON {

    public var dictionary: JSONDictionary? {
        return either.value?.cast(JSONDictionary.self)
    }

    public var array: JSONArray? {
        return either.value?.cast(JSONArray.self)
    }

    public var string: JSONString? {
        return either.value?.cast(String.self)
    }

    public var int: JSONInt? { 
        if let double = either.value?.cast(Double.self) {
            return Int64(double)
        }
        return nil
    }

    public var double: JSONDouble? {
        return either.value?.cast(Double.self)
    }

    public var bool: JSONBool? {
        return either.value?.cast(Bool.self)
    }

    public var null: JSONNull? {
        return either.value?.cast(JSONNull.self)
    }

    public var error: String? {
        return either.error
    }
}
