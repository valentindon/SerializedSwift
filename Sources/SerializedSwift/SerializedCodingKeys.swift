//
//  SerializedCodingKeys.swift
//  
//
//  Created by Dejan Skledar on 05/09/2020.
//

import Foundation

///
///
/// Dynamic Coding Key Object
///
///

public struct SerializedCodingKeys: CodingKey, Hashable {
    public var stringValue: String
    public var intValue: Int?

    public init(key: String) {
        stringValue = key
    }
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

extension SerializedCodingKeys: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
       stringValue = value
    }
}

extension SerializedCodingKeys {
  /// A textual representation of this key.
  public var description: String {
    let intValue = self.intValue?.description ?? "nil"
    return "\(type(of: self))(stringValue: \"\(stringValue)\", intValue: \(intValue))"
  }

  /// A textual representation of this key, suitable for debugging.
  public var debugDescription: String {
    return description
  }
}
