//
//  Array+Subscriptions.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import Foundation

extension Array {

    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }

        return self[index]
    }

}
