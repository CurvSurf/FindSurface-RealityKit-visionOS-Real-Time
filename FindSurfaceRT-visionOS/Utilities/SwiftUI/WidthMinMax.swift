//
//  WidthMinMax.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/29/24.
//

import Foundation
import SwiftUI



struct WidthMinMax: Equatable {
    var minValue: CGFloat = .infinity
    var maxValue: CGFloat = .zero
    
    static func minmax(_ lhs: WidthMinMax, _ rhs: WidthMinMax) -> WidthMinMax {
        return .init(minValue: min(lhs.minValue, rhs.minValue), maxValue: max(lhs.maxValue, rhs.maxValue))
    }
}

extension WidthMinMax {
    init(_ width: CGFloat) {
        self.init(minValue: width, maxValue: width)
    }
}

struct WidthMinMaxPreferenceKey: PreferenceKey {
    typealias Value = [String: WidthMinMax]
    static var defaultValue: Value { [:] }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { curr, next in
            .minmax(curr, next)
        }
    }
}

fileprivate struct WidthMinMaxEnvironmentKey: EnvironmentKey {
    static var defaultValue: WidthMinMax = .init()
}

extension EnvironmentValues {
    var widthMinMax: WidthMinMax {
        get { self[WidthMinMaxEnvironmentKey.self] }
        set { self[WidthMinMaxEnvironmentKey.self] = newValue }
    }
}

struct WidthMinMaxModifier: ViewModifier {
    
    @Environment(\.widthMinMax) private var widthMinMax
    
    let groupName: String?
    let alignment: Alignment
    let keyPath: KeyPath<WidthMinMax, CGFloat>
    
    func body(content: Content) -> some View {
        if let groupName {
            content
                .background(GeometryReader { geometry in
                    Color.clear
                        .preference(key: WidthMinMaxPreferenceKey.self,
                                    value: [groupName: .init(geometry.size.width)])
                })
                .frame(width: widthMinMax[keyPath: keyPath] > 0 ? widthMinMax[keyPath: keyPath] : nil, alignment: alignment)
        } else {
            content
        }
    }
}

extension View {
    func joinWidthMinMaxGroup(name groupName: String?, alignment: Alignment = .leading, keyPath: KeyPath<WidthMinMax, CGFloat> = \.maxValue) -> some View {
        modifier(WidthMinMaxModifier(groupName: groupName, alignment: alignment, keyPath: keyPath))
    }
}

struct WidthMinMaxGroupModifier: ViewModifier {
    
    let groupName: String?
    @State private var minmax: WidthMinMax = .init()
    
    func body(content: Content) -> some View {
        if let groupName {
            content
                .onPreferenceChange(WidthMinMaxPreferenceKey.self) { preferences in
                    minmax = preferences[groupName] ?? .init()
                }
                .environment(\.widthMinMax, minmax)
        } else {
            content
        }
    }
}

extension View {
    func makeWidthMinMaxGroup(name groupName: String?) -> some View {
        modifier(WidthMinMaxGroupModifier(groupName: groupName))
    }
}

struct WidthMinMaxGroupNameEnvironmentKey: EnvironmentKey {
    static var defaultValue: String? = nil
}

extension EnvironmentValues {
    var widthMinMaxGroupName: String? {
        get { self[WidthMinMaxGroupNameEnvironmentKey.self] }
        set { self[WidthMinMaxGroupNameEnvironmentKey.self] = newValue }
    }
}
