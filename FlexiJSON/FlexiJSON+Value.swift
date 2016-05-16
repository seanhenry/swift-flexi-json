//
//  FlexiJSON+Value.swift
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

/*: TODO:
 StringLiteralConvertible
 IntegerLiteralConvertible
 etc
 
 Loop
 
 Init from string, data, etc (Obj-C extension)
 */

// MARK: - Values
extension FlexiJSON {

    enum Value: Equatable {
        case Dictionary([JSONString : Value])
        case Array([Value])
        case String(JSONString)
        case Double(JSONDouble)
        case Bool(JSONBool)
        case Null

        static func from(anyObject: AnyObject) -> Value {
            if let string = anyObject as? JSONString {
                return .String(string)
            } else if let number = anyObject as? NSNumber {
                return from(number)
            } else if let dictionary = anyObject as? JSONDictionary {
                return from(dictionary)
            } else if let array = anyObject as? JSONArray {
                return from(array)
            } else if anyObject is NSNull {
                return .Null
            }
            fatalError()
        }

        static func from(dictionary: JSONDictionary) -> Value {
            var result = [JSONString : Value]()
            for (key, value) in dictionary {
                result[key] = from(value)
            }
            return .Dictionary(result)
        }

        static func from(array: JSONArray) -> Value {
            return .Array(array.map { from($0) })
        }

        private static func from(number: NSNumber) -> Value {
            if JSONString.fromCString(number.objCType) == "c" {
                return .Bool(number.boolValue)
            }
            return .Double(number.doubleValue)
        }

        func cast<T>(aClass: T.Type) -> T? {
            switch self {
            case .String(let s):
                return s as? T
            case .Double(let d):
                return d as? T
            case .Bool(let b):
                return b as? T
            case .Dictionary(let d):
                return jsonDictionary(d) as? T
            case .Array(let a):
                return jsonArray(a) as? T
            case .Null:
                return JSONNull() as? T
            }
        }

        private func jsonDictionary(dictionary: [JSONString : Value]) -> JSONDictionary? {
            var result = JSONDictionary()
            for (key, value) in dictionary {
                result[key] = value.cast(AnyObject.self)
            }
            return result
        }

        private func jsonArray(array: [Value]) -> JSONArray? {
            return array.map { $0.cast(AnyObject.self)! }
        }
    }
}

private func ==(lhs: [String : FlexiJSON.Value], rhs: [String : FlexiJSON.Value]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (key, _) in lhs {
        if lhs[key] != rhs[key] {
            return false
        }
    }
    return true
}

func ==(lhs: FlexiJSON.Value, rhs: FlexiJSON.Value) -> Bool {
    switch (lhs, rhs) {
    case (.String(let lhsString), .String(let rhsString)):
        return lhsString == rhsString
    case (.Dictionary(let lhsDict), .Dictionary(let rhsDict)):
        return lhsDict == rhsDict
    case (.Double(let lhsDouble), .Double(let rhsDouble)):
        return lhsDouble == rhsDouble
    case (.Bool(let lhsBool), .Bool(let rhsBool)):
        return lhsBool == rhsBool
    case (.Array(let lhsArray), .Array(let rhsArray)):
        return lhsArray == rhsArray
    case (.Null, .Null):
        return true
    default:
        return false
    }
}
