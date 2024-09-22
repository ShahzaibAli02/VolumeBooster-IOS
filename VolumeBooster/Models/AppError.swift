//
//  AppError.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 17.07.2024.
//

import Foundation

enum AppError: Error {
    case error(Error)
    case logic(String)
}
