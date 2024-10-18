//
//  Binding.swift
//  FindSurfaceST-visionOS
//
//  Created by CurvSurf-SGKim on 6/17/24.
//

import Foundation
import SwiftUI

extension Binding {
    
    func wrap<T>(wrap: @escaping (Value) -> T,
                unwrap: @escaping (T) -> Value) -> Binding<T> {
        return .init {
            wrap(wrappedValue)
        } set: { newValue in
            wrappedValue = unwrap(newValue)
        }
    }
}

extension Binding where Value: OptionSet, Value.Element == Value {
    
    func bind(_ options: Value, animate: Bool = false) -> Binding<Bool> {
        return .init {
            wrappedValue.contains(options)
        } set: { newValue in
            let body = {
                if newValue {
                    wrappedValue.insert(options)
                } else {
                    wrappedValue.remove(options)
                }
            }
            
            guard animate else {
                body()
                return
            }
            
            withAnimation {
                body()
            }
        }
    }
}

extension Binding where Value: BinaryFloatingPoint {
    
    func mapMeterToCentimeter() -> Binding<Value> {
        Binding<Value> {
            wrappedValue * 100.0
        } set: { newValue in
            wrappedValue = newValue * 0.01
        }
    }
    
    func mapNumberToPercent() -> Binding<Value> {
        Binding<Value> {
            wrappedValue * 100.0
        } set: { newValue in
            wrappedValue = newValue * 0.01
        }
    }
    
    func mapRadianToDegree() -> Binding<Value> {
        Binding<Value> {
            .degree(fromRadian: wrappedValue)
        } set: { newValue in
            wrappedValue = .radian(fromDegree: newValue)
        }
    }
}
