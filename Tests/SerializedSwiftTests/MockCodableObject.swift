//
//  MockCodableObject.swift
//  AnyDecodableTests
//
//  Created by ShopBack on 1/19/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//

import Foundation

struct MockCodableObject: Codable {
    var dict: [String: Any]
    var array: [Any]

    enum CodingKeys: String, CodingKey {
        case dict
        case array
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dict = try values.decode([String: Any].self, forKey: .dict)
        array = try values.decode([Any].self, forKey: .array)
    }

    init(dict: [String: Any], array: [Any]) {
        self.dict = dict
        self.array = array
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dict, forKey: .dict)
        try container.encode(array, forKey: .array)
    }
}

struct MockCodableTemplateData: Codable {
    var templateData: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case templateData
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        templateData = try values.decode([String: Any].self, forKey: .templateData)
        
    }

    init(dict: [String: Any]) {
        self.templateData = dict
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(templateData, forKey: .templateData)
    }
}
