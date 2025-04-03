//
//  AnyCodingKeyTests.swift
//  AnyDecodableTests
//
//  Created by ShopBack on 1/18/19.
//  Copyright © 2019 levantAJ. All rights reserved.
//

import XCTest
@testable import SerializedSwift

class  SerializedCodingKeysTests: XCTestCase {
    var sut:  SerializedCodingKeys!

    func testInitStringValue() {
        sut =  SerializedCodingKeys(stringValue: "Hello")
        XCTAssertEqual(sut.stringValue, "Hello")
        XCTAssertNil(sut.intValue)
    }

    func testInitIntValue() {
        sut = SerializedCodingKeys(intValue: 123)
        XCTAssertEqual(sut.stringValue, "123")
        XCTAssertEqual(sut.intValue, 123)
    }

}
