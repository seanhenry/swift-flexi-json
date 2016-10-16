//
//  FlexiJSON+Fragment.swift
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

import Foundation

// MARK: - Fragments
extension FlexiJSON {

    enum Fragment: Equatable {
        case dictionary([JSONString : Fragment])
        case array([Fragment])
        case string(JSONString)
        case double(JSONDouble)
        case bool(JSONBool)
        case null

        static func from(_ anyObject: Any) -> Fragment? {
            if let string = anyObject as? JSONString {
                return .string(string)
            } else if let number = anyObject as? NSNumber {
                return from(number)
            } else if let dictionary = anyObject as? JSONDictionary {
                return from(dictionary)
            } else if let array = anyObject as? JSONArray {
                return from(array)
            } else if anyObject is NSNull {
                return .null
            }
            return nil
        }

        static func from(_ dictionary: JSONDictionary) -> Fragment? {
            var result = [JSONString : Fragment]()
            for (key, value) in dictionary {
                guard let value = from(value) else {
                    return nil
                }
                result[key] = value
            }
            return .dictionary(result)
        }

        static func from(_ array: JSONArray) -> Fragment? {
            var result = [Fragment]()
            for object in array {
                guard let fragment = from(object) else {
                    return nil
                }
                result.append(fragment)
            }
            return .array(result)
        }

        private static func from(_ number: NSNumber) -> Fragment {
            if JSONString(cString: number.objCType) == "c" {
                return .bool(number.boolValue)
            }
            return .double(number.doubleValue)
        }

        func cast<T>(_ aClass: T.Type) -> T? {
            switch self {
            case .string(let s):
                return s as? T
            case .double(let d):
                return d as? T
            case .bool(let b):
                return b as? T
            case .dictionary(let d):
                return jsonDictionary(d) as? T
            case .array(let a):
                return jsonArray(a) as? T
            case .null:
                return NSNull() as? T
            }
        }

        private func jsonDictionary(_ dictionary: [JSONString : Fragment]) -> JSONDictionary? {
            var result = JSONDictionary()
            for (key, value) in dictionary {
                result[key] = value.cast(Any.self)
            }
            return result
        }

        private func jsonArray(_ array: [Fragment]) -> JSONArray? {
            return array.map { $0.cast(Any.self)! }
        }
    }
}

extension FlexiJSON.Fragment: CustomStringConvertible {

    var description: JSONString {
        switch self {
        case .string(let s):
            return s
        case .dictionary(let d):
            return d.description
        case .array(let a):
            return a.description
        case .double(let d):
            return d.description
        case .bool(let b):
            return b.description
        case .null:
            return "null"
        }
    }
}

private func ==(lhs: [String : FlexiJSON.Fragment], rhs: [String : FlexiJSON.Fragment]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (key, _) in lhs {
        if lhs[key] != rhs[key] {
            return false
        }
    }
    return true
}

func ==(lhs: FlexiJSON.Fragment, rhs: FlexiJSON.Fragment) -> Bool {
    switch (lhs, rhs) {
    case (.string(let lhsString), .string(let rhsString)):
        return lhsString == rhsString
    case (.dictionary(let lhsDict), .dictionary(let rhsDict)):
        return lhsDict == rhsDict
    case (.double(let lhsDouble), .double(let rhsDouble)):
        return lhsDouble == rhsDouble
    case (.bool(let lhsBool), .bool(let rhsBool)):
        return lhsBool == rhsBool
    case (.array(let lhsArray), .array(let rhsArray)):
        return lhsArray == rhsArray
    case (.null, .null):
        return true
    default:
        return false
    }
}
