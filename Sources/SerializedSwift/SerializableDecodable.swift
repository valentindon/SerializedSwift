//
//  SerializedDecodable.swift
//  
//
//  Created by Dejan Skledar on 05/09/2020.
//

import Foundation
import Runtime
//import Bridge
//import BSRuntime
//
//
/// SerializableDecodable protocol to be used for Decoding only
//
//

public protocol SerializableDecodable: Decodable, KeyValueCoding  {
    init()
    func decode(from decoder: Decoder) throws
    
}

//
//
/// Extending the SerializableDecodable with basic decoding of
/// current and all superclasses that have DecodableKey
//
//

public extension SerializableDecodable {
    
    /// Main decoding logic. Decodes all properties marked with @Serialized
    /// - Parameter decoder: The JSON Decoder
    /// - Throws: Throws JSON Decoding error if present
    
    //V3
    func decodeOriginal(from decoder: Decoder) throws {
        // Get the container keyed by the SerializedCodingKeys defined by the propertyWrapper @Serialized
        let container = try decoder.container(keyedBy: SerializedCodingKeys.self)
        
        //V3 - Original
        
        // Mirror for current model
        var mirror: Mirror? = Mirror(reflecting: self)
        
        // Go through all mirrors (till top most superclass)
        repeat {
            // If mirror is nil (no superclassMirror was nil), break
            guard let children = mirror?.children else { break }
            
            // Try to decode each child
            for child in children {
                guard let decodableKey = child.value as? DecodableProperty else { continue }
                
                // Get the propertyName of the property. By syntax, the property name is
                // in the form: "_name". Dropping the "_" -> "name"
                let propertyName = String((child.label ?? "").dropFirst())
                
                try decodableKey.decodeValue(from: container, propertyName: propertyName)
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil
    }
    
    //V4
    func decodeKVC(from decoder: Decoder) throws {
        
        // Get the container keyed by the SerializedCodingKeys defined by the propertyWrapper @Serialized
        let container = try decoder.container(keyedBy: SerializedCodingKeys.self)
        
        let metadata = self.metadata
        let properties = metadata.properties
    
        for property in properties {
            var this = self
            let keyName = property.name
            
            let propertyValue = this[keyName]
            
            guard case let .some(propertyValue) = propertyValue else {
                return
            }
            
            guard  let decodableProperty = propertyValue as? DecodableProperty else {
                return
            }
            
            let propertyName = keyName.hasPrefix("_") ? String(keyName.dropFirst()) : keyName
            
            try? decodableProperty.decodeValue(from: container, propertyName: propertyName)
        }
    
        
    }
    
    func call1(object: KeyValueCoding, container:  KeyedDecodingContainer<SerializedCodingKeys>, propertyName: String) throws {
        
        let propName = propertyName
        let call : (KeyValueCoding, KeyedDecodingContainer<SerializedCodingKeys>, String) throws -> Void = { (object, container, propertyName) in
            try synchronized(object as AnyObject) {
                var this = object
                let propertyValue = this[propName]
                guard case let .some(propertyValue) = propertyValue else {
                    return
                }
                
                guard  let decodableProperty = propertyValue as? DecodableProperty else {
                    return
                }
                let propertyName = String(propertyName.dropFirst())
                try decodableProperty.decodeValue(from: container, propertyName: propertyName)
                
            }
        }
        
        try call(self, container,propName)
    }
    
    // V2
    func decodeRuntime(from decoder: Decoder) throws {
        // Get the container keyed by the SerializedCodingKeys defined by the propertyWrapper @Serialized
        let container = try decoder.container(keyedBy: SerializedCodingKeys.self)
         
        let info = try RuntimeCache.shared.typeInfo(of: type(of: self))
        for property in info.properties {
            guard let rawProperty = try? property.get(from: self) else {continue}
            let propertyName = String( property.name.dropFirst())
            if let decodableProperty = rawProperty as? DecodableProperty {
                try decodableProperty.decodeValue(from: container, propertyName: propertyName)
            }else if let decodableProperty = rawProperty as? DictionaryDecodableProperty {
                try decodableProperty.decodeValue(from: container, propertyName: propertyName)
            }
        }
    
    
    }
    
    //V1 KeyPath
    func decodeKeyPath(from decoder: Decoder) throws {
        // Get the container keyed by the SerializedCodingKeys defined by the propertyWrapper @Serialized
//        let container = try decoder.container(keyedBy: SerializedCodingKeys.self)
   
//        if let obj = self as? ReflectionSerializable {
//            print("obj ReflectionSerializable:", obj, obj.properties.count, obj.properties.count)
//            for (propertyName, keyPath) in obj.properties {
//                print("propertyName:", propertyName, keyPath)
//                guard let decodableKey = obj[keyPath: keyPath] as? DecodableProperty else {continue}
//                print("decodableKey:", decodableKey)
//                try decodableKey.decodeValue(from: container, propertyName: propertyName)
//            }
//
//        }
    }
    
    func decodeBridge(from decoder: Decoder) throws {
        // Get the container keyed by the SerializedCodingKeys defined by the propertyWrapper @Serialized
        let container = try decoder.container(keyedBy: SerializedCodingKeys.self)
        let type = type(of: self.self)
//        let metadata = ClassMetadata(withType: type)
//        print(metadata)
        
//        for property in info.properties {
//            guard let decodableProperty = try? property.get(from: self) as? DecodableProperty else {continue}
//            let propertyName = String( property.name.dropFirst())
//            try decodableProperty.decodeValue(from: container, propertyName: propertyName)
//        }
    
    
    }
    
    func decode(from decoder: Decoder) throws {
        switch kindLib{
            case .Mirror:
                try self.decodeOriginal(from: decoder)
            case .KVC:
                try self.decodeKVC(from: decoder)
            case .Runtime:
                try self.decodeRuntime(from: decoder)
            case .Bridge:
                try self.decodeBridge(from: decoder)
        }
        
    }
    
    init(from decoder: Decoder) throws {
        self.init()
        try decode(from: decoder)
    }
    
}
 
@discardableResult
fileprivate func synchronized<T : AnyObject, U>(_ obj: T, closure: () throws -> U)rethrows -> U {
    objc_sync_enter(obj)
    defer {
        objc_sync_exit(obj)
    }
    return try closure()
}
