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

    var either: Either

    public init(dictionary: JSONDictionary) {
        self.init(fragment: .from(dictionary))
    }

    public init(array: JSONArray) {
        self.init(fragment: .from(array))
    }

    public init(string: JSONString) {
        self.init(fragment: .String(string))
    }

    public init(int: JSONInt) {
        self.init(fragment: .Double(Double(int)))
    }

    public init(double: JSONDouble) {
        self.init(fragment: .Double(double))
    }

    public init(bool: JSONBool) {
        self.init(fragment: .Bool(bool))
    }

    public init(null: JSONNull) {
        self.init(fragment: .Null)
    }

    public init(error: String) {
        either = .Error(error)
    }

    init(fragment: Fragment?) {
        guard let fragment = fragment else {
            either = .Error("Initialised FlexiJSON with a non json object.")
            return
        }
        either = .Fragment(fragment)
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
            if case .Dictionary(var d)? = either.fragment,
               let newFragment = newJSON.either.fragment {
                d[key] = newFragment
                either = .Fragment(.Dictionary(d))
            }
        }
        get {
            guard case .Dictionary(let d)? = either.fragment,
                  let fragment = d[key] else {
                return FlexiJSON(error: "Key '\(key)' was not found.")
            }
            return FlexiJSON(fragment: fragment)
        }
    }

    public subscript(index: Int) -> FlexiJSON {
        set(newJSON) {
            if let error = newJSON.error {
                either = .Error(error)
                return
            }
            if case .Array(var a)? = either.fragment,
               let newFragment = newJSON.either.fragment {
                a[index] = newFragment
                either = .Fragment(.Array(a))
            }
        }
        get {
            guard case .Array(let a)? = either.fragment else {
                return FlexiJSON(error: "Attempted to access a nonexistant array.")
            }
            guard index < a.count else {
                return FlexiJSON(error: "Index '\(index)' is out of bounds.")
            }
            return FlexiJSON(fragment: a[index])
        }
    }
}

// MARK: - Equatable
extension FlexiJSON: Equatable {
}

public func ==(lhs: FlexiJSON, rhs: FlexiJSON) -> Bool {
    switch (lhs.either, rhs.either) {
    case (.Fragment(let lhsFragment), .Fragment(let rhsFragment)):
        return lhsFragment == rhsFragment
    case (.Error(let lhsError), .Error(let rhsError)):
        return lhsError == rhsError
    default:
        return false
    }
}

// MARK: - Computed properties
extension FlexiJSON {

    public var dictionary: JSONDictionary? {
        return either.fragment?.cast(JSONDictionary.self)
    }

    public var array: JSONArray? {
        return either.fragment?.cast(JSONArray.self)
    }

    public var string: JSONString? {
        return either.fragment?.cast(String.self)
    }

    public var int: JSONInt? { 
        if let double = either.fragment?.cast(Double.self) {
            return Int64(double)
        }
        return nil
    }

    public var double: JSONDouble? {
        return either.fragment?.cast(Double.self)
    }

    public var bool: JSONBool? {
        return either.fragment?.cast(Bool.self)
    }

    public var null: JSONNull? {
        if either.fragment?.cast(NSNull.self) != nil {
            return JSONNull()
        }
        return nil
    }

    public var error: String? {
        return either.error
    }
}
