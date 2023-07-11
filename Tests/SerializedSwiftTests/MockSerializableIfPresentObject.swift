//
//  File.swift
//  
//
//  Created by dev on 11.07.2023.
//

import Foundation
@testable import SerializedSwift

struct MockSerializableIfPresentObject: Serializable {
    
    @Serialized(default: nil)
    var dict: [String: Any]?
    
    @Serialized(default: nil)
    var array: [Any]?
    
    init() {
    }
    
    init(dict: [String : Any]? = nil, array: [Any]? = nil) {
        self.dict = dict
        self.array = array
    }
}

struct MockSerializableTemplateDataIfPresent: Serializable {
    @Serialized(default:  nil)
    var templateData: [String: Any]?
    
    init() {
    }
    
    init(dict: [String : Any]? = nil) {
        self.templateData = dict
    }
}
