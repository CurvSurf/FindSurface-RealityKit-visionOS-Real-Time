//
//  UserDefault.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/22/24.
//

import Foundation
import Combine
import simd

public extension UserDefaults {
    protocol Supported {}
}

extension String: UserDefaults.Supported {}
extension Int: UserDefaults.Supported {}
extension Double: UserDefaults.Supported {}
extension Data: UserDefaults.Supported {}
extension Bool: UserDefaults.Supported {}
extension URL: UserDefaults.Supported {}
extension Array: UserDefaults.Supported where Element: UserDefaults.Supported {}
extension Dictionary: UserDefaults.Supported where Key: UserDefaults.Supported, Value: UserDefaults.Supported {}
extension Optional: UserDefaults.Supported where Wrapped: UserDefaults.Supported {}

extension UserDefaults {

    public protocol Key: RawRepresentable where RawValue == String {}
    
    public struct Adapter<Key: UserDefaults.Key> {
        public let storage: UserDefaults
        
        init(storage: UserDefaults = .standard) {
            self.storage = storage
        }
        
        func string(forKey key: Key) -> String? {
            return storage.object(forKey: key.rawValue) as? String
        }
        
        func integer(forKey key: Key) -> Int? {
            return storage.object(forKey: key.rawValue) as? Int
        }
        
        func double(forKey key: Key) -> Double? {
            return storage.object(forKey: key.rawValue) as? Double
        }
        
        func data(forKey key: Key) -> Data? {
            return storage.data(forKey: key.rawValue)
        }
        
        func bool(forKey key: Key) -> Bool? {
            return storage.object(forKey: key.rawValue) as? Bool
        }
        
        func url(forKey key: Key) -> URL? {
            return storage.url(forKey: key.rawValue)
        }
        
        func array<T>(forKey key: Key) -> [T]? where T: Supported {
            return storage.array(forKey: key.rawValue) as? [T]
        }
        
        func dictionary<T>(forKey key: Key) -> [String: T]? where T: Supported {
            return storage.dictionary(forKey: key.rawValue) as? [String: T]
        }
        
        func set<T: Supported>(_ value: T, forKey key: Key) {
            storage.set(value, forKey: key.rawValue)
        }
    }
}

extension SIMD {
    var toArray: [Scalar] { return (0..<scalarCount).map { self[$0] } }
}

extension UserDefaults.Adapter {
    
    func float(forKey key: Key) -> Float? {
        guard let value = double(forKey: key) else { return nil }
        return Float(value)
    }
    
    func set(_ value: Float, forKey key: Key) {
        set(Double(value), forKey: key)
    }
    
    func `enum`<T>(forKey key: Key) -> T? where T: RawRepresentable, T.RawValue == Int {
        guard let rawValue = integer(forKey: key) else { return nil }
        return T(rawValue: rawValue)!
    }
    
    func set<T>(_ value: T, forKey key: Key) where T: RawRepresentable, T.RawValue == Int {
        set(value.rawValue, forKey: key)
    }
    
    func `enum`<T>(forKey key: Key) -> T? where T: RawRepresentable, T.RawValue == String {
        guard let rawValue = string(forKey: key) else { return nil }
        return T(rawValue: rawValue)!
    }
    
    func set<T>(_ value: T, forKey key: Key) where T: RawRepresentable, T.RawValue == String {
        set(value.rawValue, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar: BinaryFloatingPoint {
        guard let array: [Double] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0) })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar: BinaryFloatingPoint {
        set(value.toArray.map { Double($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar: SignedInteger {
        guard let array: [Int] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0) })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar: SignedInteger {
        set(value.toArray.map { Int($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar == Int64 {
        guard let array: [String] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0)! })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar == Int64 {
        set(value.toArray.map { String($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar == UInt8 {
        guard let array: [String] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0, radix: 10)! })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar == UInt8 {
        set(value.toArray.map { String($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar == UInt16 {
        guard let array: [String] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0, radix: 10)! })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar == UInt16 {
        set(value.toArray.map { String($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar == UInt32 {
        guard let array: [String] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0, radix: 10)! })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar == UInt32 {
        set(value.toArray.map { String($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar == UInt64 {
        guard let array: [String] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0, radix: 10)! })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar == UInt64 {
        set(value.toArray.map { String($0) }, forKey: key)
    }
    
    func simd<T: SIMD>(forKey key: Key) -> T? where T.Scalar == UInt {
        guard let array: [String] = array(forKey: key) else { return nil }
        return .init(array.map { T.Scalar($0, radix: 10)! })
    }
    
    func set<T: SIMD>(_ value: T, forKey key: Key) where T.Scalar == UInt {
        set(value.toArray.map { String($0) }, forKey: key)
    }
    
    func simd_quatf(forKey key: Key) -> simd_quatf? {
        guard let array: [Double] = array(forKey: key) else { return nil }
        return .init(vector: .init(array.map { Float($0) }))
    }
    
    func set(_ value: simd_quatf, forKey key: Key) {
        set(value.vector.toArray.map { Double($0) }, forKey: key)
    }
    
    func simd_quatd(forKey key: Key) -> simd_quatd? {
        guard let array: [Double] = array(forKey: key) else { return nil }
        return .init(vector: .init(array))
    }
    
    func set(_ value: simd_quatd, forKey key: Key) {
        set(value.vector.toArray, forKey: key)
    }
}

extension UserDefaults {

    
    func stringValue(forKey key: String) -> String? {
        return object(forKey: key) as? String
    }
    
    func intValue(forKey key: String) -> Int? {
        return object(forKey: key) as? Int
    }
    
    func doubleValue(forKey key: String) -> Double? {
        return object(forKey: key) as? Double
    }
    
    func dataValue(forKey key: String) -> Data? {
        return object(forKey: key) as? Data
    }
    
    func dateValue(forKey key: String) -> Date? {
        return object(forKey: key) as? Date
    }
    
    func boolValue(forKey key: String) -> Bool? {
        return object(forKey: key) as? Bool
    }
    
    func urlValue(forKey key: String) -> URL? {
        return object(forKey: key) as? URL
    }
    
    func arrayValue<Element>(forKey key: String) -> [Element]? where Element: UserDefaults.Supported {
        return array(forKey: key) as? [Element]
    }
    
    func dictionaryValue<Value>(forKey key: String) -> [String: Value]? where Value: UserDefaults.Supported {
        return dictionary(forKey: key) as? [String: Value]
    }
    
    func floatValue(forKey key: String) -> Float? {
        guard let value = doubleValue(forKey: key) else { return nil }
        return Float(value)
    }
    
    func enumValue<T>(forKey key: String) -> T? where T: RawRepresentable, T.RawValue == Int {
        guard let rawValue = intValue(forKey: key),
              let value = T(rawValue: rawValue) else {
            return nil
        }
        return value
    }
    
    func enumValue<T>(forKey key: String) -> T? where T: RawRepresentable, T.RawValue == String {
        guard let rawValue = string(forKey: key),
              let value = T(rawValue: rawValue) else {
            return nil
        }
        return value
    }
    
    func set(_ value: Float, forKey key: String) {
        set(Double(value), forKey: key)
    }
    
    func set<T>(_ value: T, forKey key: String) where T: RawRepresentable, T.RawValue == Int {
        set(value.rawValue, forKey: key)
    }
    
    func set<T>(_ value: T, forKey key: String) where T: RawRepresentable, T.RawValue == String {
        set(value.rawValue, forKey: key)
    }
}
//
//@propertyWrapper
//public final class UserDefault<T> {
//
//    private let key: String
//    private var value: T
//    private let store: UserDefaults
//    private let save: (UserDefaults, _ key: String, _ value: T, _ registerInstead: Bool) -> Void
//    private let load: (UserDefaults, _ key: String) -> T
//    private var cancellable: AnyCancellable?
//
//    public var wrappedValue: T {
//        get {
//            return value
//        }
//        set {
//            self.value = newValue
//            save(store, key, newValue, false)
//        }
//    }
//
//    public init(wrappedValue initialValue: T,
//                key: String,
//                store: UserDefaults = .standard,
//                save: @escaping (UserDefaults, String, T, Bool) -> Void,
//                load: @escaping (UserDefaults, String) -> T) {
//        save(store, key, initialValue, true)
//        self.key = key
//        self.value = initialValue
//        self.store = store
//        self.save = save
//        self.load = load
//        self.cancellable = NotificationCenter.default
//            .publisher(for: UserDefaults.didChangeNotification)
//            .sink { [weak self] _ in
//                if let value = self?.load(store, key) {
//                    self?.value = value
//                }
//            }
//    }
//}
//
//public extension UserDefault {
//
//    convenience init(wrappedValue initialValue: T,
//                     key: String,
//                     store: UserDefaults = .standard) where T: UserDefaults.Supported {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            if register {
//                store.register(defaults: [key: value])
//            } else {
//                store.set(value, forKey: key)
//            }
//        } load: { store, key in
//            return store.object(forKey: key) as! T
//        }
//    }
//    
//    convenience init(wrappedValue initialValue: Float,
//                     key: String,
//                     store: UserDefaults = .standard) where T == Float {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            if register {
//                store.register(defaults: [key: Double(value)])
//            } else {
//                store.set(Double(value), forKey: key)
//            }
//        } load: { store, key in
//            return Float(store.object(forKey: key) as! Double)
//        }
//    }
//    
//    convenience init(wrappedValue initialValue: T,
//                     key: String,
//                     store: UserDefaults = .standard
//    ) where T: SIMD, T.Scalar: UserDefaults.Supported {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            let array = (0..<value.scalarCount).map { value[$0] }
//            if register {
//                store.register(defaults: [key: array])
//            } else {
//                store.set(array, forKey: key)
//            }
//        } load: { store, key in
//            return .init(store.object(forKey: key) as! [T.Scalar])
//        }
//    }
//    
//    convenience init(wrappedValue initialValue: T,
//                     key: String,
//                     store: UserDefaults = .standard
//    ) where T: SIMD, T.Scalar == Float {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            let array = (0..<value.scalarCount).map { Double(value[$0]) }
//            if register {
//                store.register(defaults: [key: array])
//            } else {
//                store.set(array, forKey: key)
//            }
//        } load: { store, key in
//            return .init((store.object(forKey: key) as! [Double]).map { Float($0) })
//        }
//    }
//    
//    convenience init(wrappedValue initialValue: simd_quatf,
//                     key: String,
//                     store: UserDefaults = .standard
//    ) where T == simd_quatf {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            let vector = value.vector
//            let array = (0..<vector.scalarCount).map { Double(vector[$0]) }
//            if register {
//                store.register(defaults: [key: array])
//            } else {
//                store.set(array, forKey: key)
//            }
//        } load: { store, key in
//            let vector = simd_float4((store.object(forKey: key) as! [Double]).map { Float($0) })
//            return .init(vector: vector)
//        }
//    }
//    
//    convenience init(wrappedValue initialValue: simd_quatd,
//                     key: String,
//                     store: UserDefaults = .standard
//    ) where T == simd_quatd {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            let vector = value.vector
//            let array = (0..<vector.scalarCount).map { vector[$0] }
//            if register {
//                store.register(defaults: [key: array])
//            } else {
//                store.set(array, forKey: key)
//            }
//        } load: { store, key in
//            let vector = simd_double4(store.object(forKey: key) as! [Double])
//            return .init(vector: vector)
//        }
//    }
//    
//    convenience init(wrappedValue initialValue: T,
//                     key: String,
//                     store: UserDefaults = .standard
//    ) where T: RawRepresentable, T.RawValue: UserDefaults.Supported {
//        self.init(wrappedValue: initialValue,
//                  key: key,
//                  store: store) { store, key, value, register in
//            if register {
//                store.register(defaults: [key: value.rawValue])
//            } else {
//                store.set(value.rawValue, forKey: key)
//            }
//        } load: { store, key in
//            return .init(rawValue: store.object(forKey: key) as! T.RawValue)!
//        }
//    }
//    
////    convenience init(wrappedValue initialValue: T,
////                     key: String,
////                     store: UserDefaults = .standard
////    ) where T: Codable {
////        self.init(wrappedValue: initialValue,
////                  key: key,
////                  store: store) { store, key, value, register in
////            let data = try! JSONEncoder().encode(value)
////            if register {
////                store.register(defaults: [key: data])
////            } else {
////                store.set(data, forKey: key)
////            }
////        } load: { store, key in
////            let data = store.data(forKey: key)!
////            return try! JSONDecoder().decode(T.self, from: data)
////        }
////    }
//}
