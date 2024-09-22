//
//  NumberFormatter + Extensions.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 17.07.2024.
//

import Foundation

extension NumberFormatter {
    
    static let player: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        return formatter
    }()
}
