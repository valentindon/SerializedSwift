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
    
    static var allTests = [
        ("testBasicJSONDecode", testBasicJSONDecode),
        ("testInheritance", testInheritance),
        ("testComposition", testComposition),
        ("testAlternateKey", testAlternateKey),
        ("testAlternateKeyAndPrimaryKeyBothPresent", testAlternateKeyAndPrimaryKeyBothPresent),
        ("testIntDoubleValuesPresent", testIntDoubleValuesPresent)
    ]
}
