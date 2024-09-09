//
//  File.swift
//  
//
//  Created by dev on 31.12.2022.
//

import Foundation
import Runtime

internal struct HashedType : Hashable
{
    public let hashValue: Int

    public init(_ type: Any.Type)
    {
        hashValue = unsafeBitCast(type, to: Int.self)
    }

    public init<T>(_ pointer: UnsafePointer<T>)
    {
        hashValue = pointer.hashValue
    }

    public static func == (lhs: HashedType, rhs: HashedType) -> Bool
    {
        return lhs.hashValue == rhs.hashValue
    }
}



class RuntimeCache {
    
    static let shared = RuntimeCache()
     
    private var cache = [HashedType : TypeInfo]()
    
    func typeInfo(of type: Any.Type) throws -> TypeInfo {
        try synchronized(self) {
            
            let hashedType = HashedType(type)
//            print("check exist type: ", key)
            guard let typeInfo = cache[hashedType] else {
//                print("added new metadata: ", key)
                let typeInfo = try Runtime.typeInfo(of: type)
                cache[hashedType]  = typeInfo
//                print("cache count: ", cache.count)
                return typeInfo
            }
//            print("type exist: ", key)
            return typeInfo
        }
    }
    
    func clearCache() {
        synchronized(self) {
            cache.removeAll()
        }
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
