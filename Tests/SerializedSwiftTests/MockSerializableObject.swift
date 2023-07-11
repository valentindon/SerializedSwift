//
//  File.swift
//  
//
//  Created by dev on 11.07.2023.
//

import Foundation
@testable import SerializedSwift
struct MockSerializableObject: Serializable {
    
    @Serialized(default: [String:Any]())
    var dict: [String: Any]
    
    @Serialized(default: [Any]())
    var array: [Any]
    
    init() {
    }
    
    init(dict: [String : Any] = [String : Any](), array: [Any] = [Any]()) {
        self.dict = dict
        self.array = array
    }
}

struct MockSerializableTemplateData: Serializable {
    @Serialized(default:  [String: Any]())
    var templateData: [String: Any]
    
    init() {
    }
    
    init(dict: [String : Any] = [String : Any]()) {
        self.templateData = dict
    }
}
