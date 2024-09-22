//
//  AppDelegate.swift
//  VolumeBooster
//
//  Created by Taras Chernysh on 15.07.2024.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupNavBar()
        return true
    }
    
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowImage = UIImage()
//        appearance.backgroundEffect = nil
        UINavigationBar.appearance().standardAppearance = appearance
    }
}
