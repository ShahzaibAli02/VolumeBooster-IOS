//
//  VolumeBoosterApp.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 07.07.2024.
//

import SwiftUI

@main
struct VolumeBoosterApp: App {    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject private var appManager = AppManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appManager)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
