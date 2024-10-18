//
//  Formatter.swift
//  FindSurfaceRR-visionOS
//
//  Created by CurvSurf-SGKim on 8/27/24.
//

import Foundation
import SwiftUI

extension Formatter {
    
    static func decimal(_ fractionDigits: Int) -> Formatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = fractionDigits
        return formatter
    }
    
    static func percent(_ fractionDigits: Int) -> Formatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = fractionDigits
        return formatter
    }
    
    static func centimeter(_ maximumFactionDigits: Int) -> CentimeterFormatter {
        let formatter = CentimeterFormatter()
        formatter.maximumFractionDigits = maximumFactionDigits
        return formatter
    }
    
    static func measurement(_ maximumFractionDigits: Int, style: UnitStyle = .medium) -> MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = maximumFractionDigits
        formatter.unitStyle = style
        formatter.unitOptions = .providedUnit
        return formatter
    }
}

final class CentimeterFormatter: NumberFormatter {
    
    let symbol: String = " cm"
    
    override init() {
        super.init()
        self.maximumFractionDigits = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for obj: Any?) -> String? {
        guard let obj else { return nil }
        return "\(obj)\(symbol)"
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = NumberFormatter().number(from: string.replacingOccurrences(of: symbol, with: ""))
        return true
    }
}
