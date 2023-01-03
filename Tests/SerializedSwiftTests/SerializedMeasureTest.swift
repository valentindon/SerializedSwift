//
//  SerializedMeasureTest.swift
//  
//
//  Created by dev on 30.12.2022.
//

import XCTest
import SerializedSwift

final class SerializedMeasureTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
//V3
//count: 10000
//[Child Encodable time duration: 0.35595500469207764 s.
//isEqual: true
//[Child Decodable Time duration: 0.4410440921783447 s.
//[Child Full time duration: 0.7969990968704224 s.
    func testExample() throws {
        let input = Child()
        Measure.test(input, count: 10000)
    }

    func testPerformanceExample() throws {
        let input1 = Child()
        let input2 = Child()
        // This is an example of a performance test case.
        
        self.measure {
            // Put the code you want to measure the time of here.
//            Measure.test(input1, count: 10)
//            Measure.test(input2, count: 10)
            
        }
        
    }

}

class Base: Serializable {
    @Serialized(default: Int.random(in: 1...10) )
    var id: Int
    
    @Serialized(default:"name")
    var name: String
    required init(){}
}

class Child:  Base {
    
    @Serialized(alternateKey: "owner_Name", default:"ownerName")
    var ownerName: String


    required init() {
        super.init()
       
    }
    
}

extension Base: Equatable {
    static func == (lhs: Base, rhs: Base) -> Bool {
        lhs.id == rhs.id
    }
}

extension Child {
    static func == (lhs: Child, rhs: Child) -> Bool {
        lhs.ownerName == rhs.ownerName &&  lhs.id == rhs.id && lhs.name == rhs.name
    }
}

public struct Measure {
    private static let jsonEncoder = JSONEncoder()
    private static let jsonDecoder = JSONDecoder()
    
    static func test<T>( _ input: T, count: Int = 1) where T: Codable & Equatable {
        let inputArr = Array(repeating: input, count: count)
        print("count:", inputArr.count)
        var startTime = CFAbsoluteTimeGetCurrent()
        
        guard let jsonData = try? jsonEncoder.encode(inputArr) else {
            XCTFail("Encoded fail")
            return
        }
        let encodableTimeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        var logText =  "[\(T.self) Encodable time duration: \(encodableTimeElapsed) s."
        print(logText)
        //            let jsonString = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        //            print(jsonString as Any)
        let type = Swift.type(of: input)
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        if let outputArr = try? jsonDecoder.decode(Array<T>.self, from: jsonData) {
            if let output = outputArr.first{
                print("isEqual:", input == output)
                XCTAssertEqual(input, output)
            }
        }
        let decodableTimeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        logText =  "[\(T.self) Decodable Time duration: \(decodableTimeElapsed) s."
        print(logText)
        
        logText =  "[\(T.self) Full time duration: \(encodableTimeElapsed + decodableTimeElapsed) s."
        print(logText)
        
        
        
    }
    
    static func encodeTest<T>( _ input: T, count: Int = 1) where T: Codable & Equatable {
        let inputArr = Array(repeating: input, count: count)
        
        var startTime = CFAbsoluteTimeGetCurrent()
        
        guard let jsonData = try? jsonEncoder.encode(inputArr) else {
            XCTFail("Encoded fail")
            return
        }
        let encodableTimeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        var logText =  "[\(T.self) Encodable time duration: \(encodableTimeElapsed) s."
        print(logText)
        //            let jsonString = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        //            print(jsonString as Any)
        let type = Swift.type(of: input)
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        if let outputArr = try? jsonDecoder.decode(Array<T>.self, from: jsonData) {
            if let output = outputArr.first{
                print("isEqual:", input == output)
                XCTAssertEqual(input, output)
            }
        }
        let decodableTimeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        logText =  "[\(T.self) Decodable Time duration: \(decodableTimeElapsed) s."
        print(logText)
        
        logText =  "[\(T.self) Full time duration: \(encodableTimeElapsed + decodableTimeElapsed) s."
        print(logText)
        
        
        
    }
}
