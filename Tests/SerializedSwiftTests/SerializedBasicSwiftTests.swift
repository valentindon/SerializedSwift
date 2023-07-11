import XCTest
@testable import SerializedSwift

final class SerializedBasicSwiftTests: XCTestCase {
    
    func testBasicJSONDecode() {
        class User: Serializable {
            @Serialized(default: "No name")
            var surname: String?
            
            @Serialized("home_address")
            var address: String
            
            @Serialized("phone_number")
            var phoneNumber: String?
            
            @Serialized(alternateKey: "authorization")
            var token: String
            
            required init() {}
        }
        
        let json = """
          {
              "surname": "Dejan",
              "home_address": "Slovenia",
              "phone_number": "+386 30 123 456",
              "authorization": "Bearer jyQ84iajndfjdkfbn9342938jf"
          }
          """
        guard let data = json.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            
            XCTAssertEqual(user.surname, "Dejan")
            XCTAssertEqual(user.address, "Slovenia")
            XCTAssertEqual(user.phoneNumber, "+386 30 123 456")
            XCTAssertEqual(user.token, "Bearer jyQ84iajndfjdkfbn9342938jf")
            
            let json = try JSONEncoder().encode(user)
            let newUser = try JSONDecoder().decode(User.self, from: json)
            
            XCTAssertEqual(newUser.surname, "Dejan")
            XCTAssertEqual(newUser.address, "Slovenia")
            XCTAssertEqual(newUser.phoneNumber, "+386 30 123 456")
            XCTAssertEqual(newUser.token, "Bearer jyQ84iajndfjdkfbn9342938jf")
            
        } catch {
            XCTFail()
        }
    }
    
    func testInheritance() {
        class Foo: Serializable {
            @Serialized
            var foo: String?
            
            required init() {}
        }
        
        class Bar: Foo {
            @Serialized("bar")
            var bar: String?
            
            @Serialized
            var boo: String?
            
            required init() {}
        }
        
        let json = """
          {
              "foo": "Foo is in superclass!",
              "bar": "Bar is in subclass!"
          }
          """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let object = try JSONDecoder().decode(Bar.self, from: data)
            
            XCTAssertEqual(object.foo, "Foo is in superclass!")
            XCTAssertEqual(object.bar, "Bar is in subclass!")
            XCTAssertEqual(object.boo, nil)
            
            let json = try JSONEncoder().encode(object)
            let newObject = try JSONDecoder().decode(Bar.self, from: json)
            
            XCTAssertEqual(newObject.foo, "Foo is in superclass!")
            XCTAssertEqual(newObject.bar, "Bar is in subclass!")
            XCTAssertEqual(newObject.boo, nil)
            
        } catch {
            XCTFail()
        }
    }
    
    func testComposition() {
        class Bar: Serializable {
            @Serialized
            var fooBar: String?
            
            required init() {}
        }
        
        class Foo: Serializable {
            @Serialized
            var foo: String?
            
            @Serialized
            var bar: Bar?

            @Serialized(default: [])
            var allBars: [Foo]
            
            @Serialized
            var sumBars: [Foo]?
            
            required init() {}
        }
        
        let json = """
          {
              "foo": "Basic foo!",
              "bar": {
                "fooBar": "Bar for foo!"
              }
          }
          """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let object = try JSONDecoder().decode(Foo.self, from: data)
            
            XCTAssertEqual(object.foo, "Basic foo!")
            XCTAssertEqual(object.bar?.fooBar, "Bar for foo!")
            XCTAssertTrue(object.allBars.isEmpty)
            XCTAssertNil(object.sumBars)
            
            let json = try JSONEncoder().encode(object)
            let newObject = try JSONDecoder().decode(Foo.self, from: json)
            
            XCTAssertEqual(newObject.foo, "Basic foo!")
            XCTAssertEqual(newObject.bar?.fooBar, "Bar for foo!")
            XCTAssertTrue(newObject.allBars.isEmpty)
            XCTAssertNil(newObject.sumBars)
            
        } catch {
            XCTFail()
        }
    }
    
    func testAlternateKey() {
        class User: Serializable {
            @Serialized(alternateKey: "full_name")
            var name: String?
            
            @Serialized(alternateKey: "town", default: "")
            var post: String?
            
            @Serialized("points", alternateKey: "streak", default: 0)
            var score: Int
            
            required init() {}
        }
        let jsonString = """
          {
              "full_name": "Foo Bar",
              "town": "Maribor",
              "streak": 10
          }
          """
        
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let object = try JSONDecoder().decode(User.self, from: data)
            
            XCTAssertEqual(object.name, "Foo Bar")
            XCTAssertEqual(object.post, "Maribor")
            XCTAssertEqual(object.score, 10)
            
            let json = try JSONEncoder().encode(object)
            let newObject = try JSONDecoder().decode(User.self, from: json)
            
            XCTAssertEqual(newObject.name, "Foo Bar")
            XCTAssertEqual(newObject.post, "Maribor")
            XCTAssertEqual(newObject.score, 10)
           
            
            guard let newJsonString = String(data: json, encoding: .utf8) else {
                XCTFail()
                return
            }
            print(jsonString, newJsonString)

        } catch {
            XCTFail()
        }
    }
    
    func testAlternateKeyAndPrimaryKeyBothPresent() {
        struct User: Serializable {
            @Serialized(alternateKey: "full_name")
            var name: String?
        }
        
        let json = """
          {
              "full_name": "Foo Bar",
              "name": "Foo"
          }
          """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let object = try JSONDecoder().decode(User.self, from: data)
            
            XCTAssertEqual(object.name, "Foo")
            
            let json = try JSONEncoder().encode(object)
            let newObject = try JSONDecoder().decode(User.self, from: json)
            
            XCTAssertEqual(newObject.name, "Foo")
            
        } catch {
            XCTFail()
        }
    }
    
    func testIntDoubleValuesPresent() {
        struct IntDouble: Serializable {
            @Serialized()
            var intField: Int
            @Serialized()
            var doubleField: Double
        }
        
        let json = """
          {
              "intField": 10,
              "doubleField": 20
          }
          """
        
        guard let data = json.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        do {
            let object = try JSONDecoder().decode(IntDouble.self, from: data)
            
            XCTAssertEqual(object.intField, 10)
            
            let json = try JSONEncoder().encode(object)
            let newObject = try JSONDecoder().decode(IntDouble.self, from: json)
            
            XCTAssertEqual(newObject.doubleField, 20)
            
        } catch {
            XCTFail()
        }
    }
    
    func testAnyValuesIfPresent() {
        
        let jsonDic: [String : Any] = ["dict": ["intField": 20, "doubleField": 21.51,"arrays": [["id": 1, "stringField": "1"],["id": 2, "stringField": "2"],["id": 3, "stringField": "3"]]], "array": [1,2,3,4,5]]
        
        let json = """
          {
              "dict": {
                  "intField": 20,
                  "doubleField": 21.51,
                  "arrays":[
                      { "id": 1, "stringField": "1"},
                      {"id": 2, "stringField": "2"},
                      {"id": 3, "stringField": "3"}
                      ]
              },
              "array": [
                      { "id": 1, "stringField": "1"},
                      {"id": 2, "stringField": "2"},
                      {"id": 3, "stringField": "3"}
                      ]
              }
          """
        let jsonString = json.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            XCTFail()
            return
        }
        print(string)
        let expectedSerializableResult = MockSerializableIfPresentObject(dict: jsonDic["dict"] as? [String : Any], array: jsonDic["array"] as? [Any])
        let expectedCodableResult = MockCodableIfPresentObject(dict: jsonDic["dict"] as? [String : Any], array: jsonDic["array"] as? [Any])
        
        var expSerData: Data!
        XCTAssertNoThrow(expSerData = try JSONEncoder().encode(expectedSerializableResult))
        let stringSer = String(data: expSerData, encoding: .utf8)
        
        var expCodData: Data!
        XCTAssertNoThrow(expCodData = try JSONEncoder().encode(expectedCodableResult))
        let stringCod = String(data: expCodData, encoding: .utf8)
        
        
        //Check Encode flow and compare codable and serializable
        XCTAssertEqual(stringSer?.count, stringCod?.count)
        var codableObject: MockCodableIfPresentObject!
        XCTAssertNoThrow( codableObject = try JSONDecoder().decode(MockCodableIfPresentObject.self, from: expSerData))
        
        var serializableObject:MockSerializableIfPresentObject!
        XCTAssertNoThrow( serializableObject = try JSONDecoder().decode(MockSerializableIfPresentObject.self, from: expSerData))
        
        XCTAssertEqual(codableObject.dict?.count, serializableObject.dict?.count)
        
        XCTAssertEqual(codableObject.dict?["doubleField"] as? Double, serializableObject.dict?["doubleField"] as? Double)
        
        XCTAssertEqual(codableObject.dict?["intField"] as? Double, serializableObject.dict?["intField"] as? Double)
        
        XCTAssertEqual(codableObject.array?.count, serializableObject.array?.count)
        
        XCTAssertEqual((codableObject.dict?["arrays"] as? Array<Any>)?.count, (serializableObject.dict?["arrays"] as? Array<Any>)?.count)
        
        var crossCodableData:Data!
        XCTAssertNoThrow( crossCodableData = try JSONEncoder().encode(codableObject))
        
        var crossSerilizableData: Data!
        XCTAssertNoThrow( crossSerilizableData = try JSONEncoder().encode(serializableObject))
        
        var crossCodableObject: MockCodableIfPresentObject!
        XCTAssertNoThrow( crossCodableObject = try JSONDecoder().decode(MockCodableIfPresentObject.self, from: crossSerilizableData))
        
        var crossSerilizableObject: MockSerializableIfPresentObject!
        XCTAssertNoThrow( crossSerilizableObject = try JSONDecoder().decode(MockSerializableIfPresentObject.self, from: crossCodableData))
        
        XCTAssertEqual(crossCodableObject.dict?.count, crossSerilizableObject.dict?.count)
        
        XCTAssertEqual(crossCodableObject.dict?["doubleField"] as? Double, crossSerilizableObject.dict?["doubleField"] as? Double)
        
        XCTAssertEqual(crossCodableObject.dict?["intField"] as? Double, crossSerilizableObject.dict?["intField"] as? Double)
        
        XCTAssertEqual(crossCodableObject.array?.count, crossSerilizableObject.array?.count)
        
        XCTAssertEqual((crossCodableObject.dict?["arrays"] as? Array<Any>)?.count, (crossSerilizableObject.dict?["arrays"] as? Array<Any>)?.count)
    }
    
    func testAnyValues() {
        
        let jsonDic: [String : Any] = ["dict": ["intField": 20, "doubleField": 21.51,"arrays": [["id": 1, "stringField": "1"],["id": 2, "stringField": "2"],["id": 3, "stringField": "3"]]], "array": [1,2,3,4,5]]
        
        let json = """
          {
              "dict": {
                  "intField": 20,
                  "doubleField": 21.51,
                  "arrays":[
                      { "id": 1, "stringField": "1"},
                      {"id": 2, "stringField": "2"},
                      {"id": 3, "stringField": "3"}
                      ]
              },
              "array": [
                      { "id": 1, "stringField": "1"},
                      {"id": 2, "stringField": "2"},
                      {"id": 3, "stringField": "3"}
                      ]
              }
          """
        let jsonString = json.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail()
            return
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            XCTFail()
            return
        }
        print(string)
        let expectedSerializableResult = MockSerializableObject(dict: jsonDic["dict"] as! [String : Any], array: jsonDic["array"] as! [Any] )
        let expectedCodableResult = MockCodableObject(dict: jsonDic["dict"] as! [String : Any], array: jsonDic["array"] as! [Any])
        
        var expSerData: Data!
        XCTAssertNoThrow(expSerData = try JSONEncoder().encode(expectedSerializableResult))
        let stringSer = String(data: expSerData, encoding: .utf8)
        
        var expCodData: Data!
        XCTAssertNoThrow(expCodData = try JSONEncoder().encode(expectedCodableResult))
        let stringCod = String(data: expCodData, encoding: .utf8)
        
        
        //Check Encode flow and compare codable and serializable
        XCTAssertEqual(stringSer, stringCod)
        var codableObject: MockCodableObject!
        XCTAssertNoThrow( codableObject = try JSONDecoder().decode(MockCodableObject.self, from: expSerData))
        
        var serializableObject:MockSerializableObject!
        XCTAssertNoThrow( serializableObject = try JSONDecoder().decode(MockSerializableObject.self, from: expSerData))
        
        XCTAssertEqual(codableObject.dict.count, serializableObject.dict.count)
        
        XCTAssertEqual(codableObject.dict["doubleField"] as? Double, serializableObject.dict["doubleField"] as? Double)
        
        XCTAssertEqual(codableObject.dict["intField"] as? Double, serializableObject.dict["intField"] as? Double)
        
        XCTAssertEqual(codableObject.array.count, serializableObject.array.count)
        
        XCTAssertEqual((codableObject.dict["arrays"] as! Array<Any>).count, (serializableObject.dict["arrays"] as! Array<Any>).count)
        
        var crossCodableData:Data!
        XCTAssertNoThrow( crossCodableData = try JSONEncoder().encode(codableObject))
        
        var crossSerilizableData: Data!
        XCTAssertNoThrow( crossSerilizableData = try JSONEncoder().encode(serializableObject))
        
        var crossCodableObject: MockCodableObject!
        XCTAssertNoThrow( crossCodableObject = try JSONDecoder().decode(MockCodableObject.self, from: crossSerilizableData))
        
        var crossSerilizableObject: MockSerializableObject!
        XCTAssertNoThrow( crossSerilizableObject = try JSONDecoder().decode(MockSerializableObject.self, from: crossCodableData))
        
        XCTAssertEqual(crossCodableObject.dict.count, crossSerilizableObject.dict.count)
        
        XCTAssertEqual(crossCodableObject.dict["doubleField"] as? Double, crossSerilizableObject.dict["doubleField"] as? Double)
        
        XCTAssertEqual(crossCodableObject.dict["intField"] as? Double, crossSerilizableObject.dict["intField"] as? Double)
        
        XCTAssertEqual(crossCodableObject.array.count, crossSerilizableObject.array.count)
        
        XCTAssertEqual((crossCodableObject.dict["arrays"] as! Array<Any>).count, (crossSerilizableObject.dict["arrays"] as! Array<Any>).count)
    }
    
    func testTemplateDataPresent() {
        
        let expectedSerializableResult = MockSerializableTemplateDataIfPresent(dict: templateData)
        let expectedCodableResult = MockCodableTemplateDataIfPresent(dict: templateData)
        
        var expSerData: Data!
        XCTAssertNoThrow(expSerData = try JSONEncoder().encode(expectedSerializableResult))
        let stringSer = String(data: expSerData, encoding: .utf8)
        
        var expCodData: Data!
        XCTAssertNoThrow(expCodData = try JSONEncoder().encode(expectedCodableResult))
        let stringCod = String(data: expCodData, encoding: .utf8)
        
        
        //Check Encode flow and compare codable and serializable
        XCTAssertEqual(stringSer?.count, stringCod?.count)
        var codableObject: MockCodableTemplateDataIfPresent!
        XCTAssertNoThrow( codableObject = try JSONDecoder().decode(MockCodableTemplateDataIfPresent.self, from: expSerData))
        
        var serializableObject:MockSerializableTemplateDataIfPresent!
        XCTAssertNoThrow( serializableObject = try JSONDecoder().decode(MockSerializableTemplateDataIfPresent.self, from: expSerData))
        
        XCTAssertEqual(codableObject.templateData?.count, serializableObject.templateData?.count)
        
        var crossCodableData:Data!
        XCTAssertNoThrow( crossCodableData = try JSONEncoder().encode(codableObject))
        
        var crossSerilizableData: Data!
        XCTAssertNoThrow( crossSerilizableData = try JSONEncoder().encode(serializableObject))
        
        var crossCodableObject: MockCodableTemplateDataIfPresent!
        XCTAssertNoThrow( crossCodableObject = try JSONDecoder().decode(MockCodableTemplateDataIfPresent.self, from: crossSerilizableData))
        
        var crossSerilizableObject: MockSerializableTemplateDataIfPresent!
        XCTAssertNoThrow( crossSerilizableObject = try JSONDecoder().decode(MockSerializableTemplateDataIfPresent.self, from: crossCodableData))
        
        XCTAssertEqual(crossCodableObject.templateData?.count, crossSerilizableObject.templateData?.count)
        
        
    }
    
    func testTemplateData() {
        
        let expectedSerializableResult = MockSerializableTemplateData(dict: templateData)
        let expectedCodableResult = MockCodableTemplateData(dict: templateData)
        
        var expSerData: Data!
        XCTAssertNoThrow(expSerData = try JSONEncoder().encode(expectedSerializableResult))
        let stringSer = String(data: expSerData, encoding: .utf8)
        
        var expCodData: Data!
        XCTAssertNoThrow(expCodData = try JSONEncoder().encode(expectedCodableResult))
        let stringCod = String(data: expCodData, encoding: .utf8)
        
        
        //Check Encode flow and compare codable and serializable
        XCTAssertEqual(stringSer?.count, stringCod?.count)
        var codableObject: MockCodableTemplateData!
        XCTAssertNoThrow( codableObject = try JSONDecoder().decode(MockCodableTemplateData.self, from: expSerData))
        
        var serializableObject:MockSerializableTemplateData!
        XCTAssertNoThrow( serializableObject = try JSONDecoder().decode(MockSerializableTemplateData.self, from: expSerData))
        
        XCTAssertEqual(codableObject.templateData.count, serializableObject.templateData.count)
        let codMainProducts: [Any] = ((codableObject.templateData["templateData"] as! [String: Any]) ["orders"] as! [String: Any])["mainProducts"]  as! [Any]
        let serMainProducts: [Any] = ((serializableObject.templateData["templateData"] as! [String: Any])["orders"] as! [String: Any])["mainProducts"]  as! [Any]
        
        XCTAssertEqual(codMainProducts.count, serMainProducts.count)
        XCTAssertEqual((codMainProducts.first! as! [String:Any]).count, (serMainProducts.first! as! [String:Any]).count)
        
       
        var crossCodableData:Data!
        XCTAssertNoThrow( crossCodableData = try JSONEncoder().encode(codableObject))
        
        var crossSerilizableData: Data!
        XCTAssertNoThrow( crossSerilizableData = try JSONEncoder().encode(serializableObject))
        
        var crossCodableObject: MockCodableTemplateData!
        XCTAssertNoThrow( crossCodableObject = try JSONDecoder().decode(MockCodableTemplateData.self, from: crossSerilizableData))
        
        var crossSerilizableObject: MockSerializableTemplateData!
        XCTAssertNoThrow( crossSerilizableObject = try JSONDecoder().decode(MockSerializableTemplateData.self, from: crossCodableData))
        
        XCTAssertEqual(crossCodableObject.templateData.count, crossSerilizableObject.templateData.count)
        
        let crossCodMainProducts: [Any] = ((crossCodableObject.templateData["templateData"] as! [String: Any]) ["orders"] as! [String: Any])["mainProducts"]  as! [Any]
        let crossSerMainProducts: [Any] = ((crossSerilizableObject.templateData["templateData"] as! [String: Any])["orders"] as! [String: Any])["mainProducts"]  as! [Any]
        
        XCTAssertEqual(crossCodMainProducts.count, crossSerMainProducts.count)
        XCTAssertEqual((crossCodMainProducts.first! as! [String:Any]).count, (crossSerMainProducts.first! as! [String:Any]).count)
        
    }
    
    func testTemplateOnly (){
        
        let data = try? JSONSerialization.data(withJSONObject: templateData["templateData"], options: .fragmentsAllowed)
        print(data)
    }
    static var allTests = [
        ("testBasicJSONDecode", testBasicJSONDecode),
        ("testInheritance", testInheritance),
        ("testComposition", testComposition),
        ("testAlternateKey", testAlternateKey),
        ("testAlternateKeyAndPrimaryKeyBothPresent", testAlternateKeyAndPrimaryKeyBothPresent),
        ("testIntDoubleValuesPresent", testIntDoubleValuesPresent)
    ]
}
