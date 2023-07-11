//
//  File.swift
//  
//
//  Created by dev on 11.07.2023.
//

import Foundation
@testable import SerializedSwift

protocol Metadata {}
extension Metadata {
    func allProperties() -> [String: Any] {
        return serializeObject(object: self)
    }
    
    internal
    func serializeObject<T>(object: T?) -> [String: Any] {
        var dictionary = [String: Any]()
        guard let object = object else {
            return dictionary
        }
        var mirror: Mirror! = Mirror(reflecting: object)
        repeat {
            for (key, value) in mirror.children {
                guard let propertyName = key else { continue }
                
                print(propertyName)
                
                var keyName = propertyName
                if keyName.hasPrefix("_") {
                    keyName = String(keyName.dropFirst())
                }
                
                // Check if the property has @Serialized attribute
                if let wrappedValue = getWrappedValue(object: value, propertyName: propertyName), let unwrapped = unwrapValue(wrappedValue: wrappedValue){
                    if isPrimitiveType(unwrapped) {
                        dictionary[keyName] = unwrapped
                    }else if String(describing: unwrapped) == "nil" {
                        dictionary[keyName] = NSNull()
                    }else if  case Optional<Any>.none = unwrapped {
                        dictionary[keyName] = NSNull()
                    }else if Mirror(reflecting: unwrapped).displayStyle == .enum {
                        if let rawValue = (unwrapped as? (any RawRepresentable))?.rawValue {
                            dictionary[keyName] = rawValue
                        }else {
                            dictionary[keyName] = unwrapped
                        }
                        
                    }else if Mirror(reflecting: unwrapped).displayStyle == .collection, let items = unwrapped as? Array<Any> {
                        let nestedArray =  items.map{serializeObject(object:$0)}
                        dictionary[keyName] = nestedArray.count == 0 ? unwrapped : nestedArray
                    }else if Mirror(reflecting: unwrapped).displayStyle == .dictionary, let items = unwrapped as? Dictionary<String, Any> {
                        let nestedDictionary =  items.mapValues{serializeObject(object:$0)}
                        dictionary[keyName] = nestedDictionary.count == 0 ? unwrapped : nestedDictionary
                    }else {
                        let nestedDictionary = serializeObject(object: unwrapped)
                        dictionary[keyName] = nestedDictionary.count == 0 ? unwrapped : nestedDictionary
                    }
                    
                } else if let computedValue = getComputedValue(object: object, propertyName: propertyName) {
                    dictionary[keyName] = computedValue
                    
                } else {
                    // Serialize the property value
                    let nestedDictionary = serializeObject(object: value)
                    dictionary[keyName] = nestedDictionary.count == 0 ? value : nestedDictionary
                }
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
        return dictionary
    }
    
    func getWrappedValue<T>(object: T, propertyName: String) -> Any? {
        let mirror = Mirror(reflecting: object)
        guard object.self is SerializedProtocol else {
            return nil
        }
        
        
        for (key, value) in mirror.children {
            
            if key == "_value" {
                if let value = value as? Int {
                    return value
                }else if let value = value as? Int8 {
                    return value
                }else if let value = value as? Int16 {
                    return value
                }else if let value = value as? Int32 {
                    return value
                }else if let value = value as? Int64 {
                    return value
                }else if let value = value as? UInt {
                    return value
                }else if let value = value as? UInt8 {
                    return value
                }else if let value = value as? UInt16 {
                    return value
                }else if let value = value as? UInt32 {
                    return value
                }else if let value = value as? UInt64 {
                    return value
                }else if let value = value as? Float {
                    return value
                }else if let value = value as? Double {
                    return value
                }else if let value = value as? Bool {
                    return value
                }else if let value = value as? String {
                    return value
                }else if let value = value as? Array<Any> {
                    return value
                }else if let value = value as? Dictionary<String, Any> {
                    return value
                }else {
                    return value
                }
            }
        }
        
        return nil
    }
    
    
    func getComputedValue<T>(object: T, propertyName: String) -> Any? {
        let mirror = Mirror(reflecting: object)
        
        if let value = mirror.descendant(propertyName) {
            if let value = value as? Int {
                return value
            }else if let value = value as? Int8 {
                return value
            }else if let value = value as? Int16 {
                return value
            }else if let value = value as? Int32 {
                return value
            }else if let value = value as? Int64 {
                return value
            }else if let value = value as? UInt {
                return value
            }else if let value = value as? UInt8 {
                return value
            }else if let value = value as? UInt16 {
                return value
            }else if let value = value as? UInt32 {
                return value
            }else if let value = value as? UInt64 {
                return value
            }else if let value = value as? Float {
                return value
            }else if let value = value as? Double {
                return value
            }else if let value = value as? Bool {
                return value
            }else if let value = value as? String {
                return value
            }else if let value = value as? Array<Any> {
                return value
            }else if let value = value as? Dictionary<AnyHashable, Any> {
                return value
            }else {
                return value
            }
        }
        
        return nil
    }
    
    func isPrimitiveType(_ value: Any) -> Bool {
        return value is Int || value is UInt || value is Bool || value is String || value is Double || value is Float
    }
    
    func unwrapValue(wrappedValue: Any) -> Any? {
        var result: Any? = wrappedValue
        let mirror = Mirror(reflecting: wrappedValue)
        
        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                let unwrappedChild = child.value
                result = unwrapValue(wrappedValue: unwrappedChild)
            }
            return result
        } else {
            return result
        }
    }
    
}

extension Dictionary where Value: Any {
  
    static public func == <K, L: Hashable, R: Hashable>(lhs: [K: L], rhs: [K: R] ) -> Bool {
       (lhs as NSDictionary).isEqual(to: rhs)
    }
    static public func ==(lhs: [String: Any], rhs: [String: Any] ) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
    
    static public func ==(lhs: Dictionary, rhs: Dictionary ) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
    
}

extension Dictionary {
    
    /// - Description
    ///   - The function will return a value on given keypath
    ///   - if Dictionary is ["team": ["name": "KNR"]]  the to fetch team name pass keypath: team.name
    ///   - If you will pass "team" in keypath it will return  team object
    /// - Parameter keyPath: keys joined using '.'  such as "key1.key2.key3"
    func valueForKeyPath(_ keyPath: String) -> Any? {
        let array = keyPath.components(separatedBy: ".")
        return value(array, self)
        
    }
    
    /// - Description:"
    ///   - The function will return a value on given keypath. It keep calling recursively until reach to the keypath. Here are few sample:
    ///   - if Dictionary is ["team": ["name": "KNR"]]  the to fetch team name pass keypath: team.name
    ///   - If you will pass "team" in keypath it will return  team object
    /// - Parameters:
    ///   - keys: array of keys in a keypath
    ///   - dictionary: The dictionary in which value need to find
    private func value(_ keys: [String], _ dictionary: Any?) -> Any? {
        guard let dictionary = dictionary as? [String: Any],  !keys.isEmpty else {
            return nil
        }
        if keys.count == 1 {
            return dictionary[keys[0]]
        }
        return value(Array(keys.suffix(keys.count - 1)), dictionary[keys[0]])
    }
}
