//
//  MemorizingApp.swift
//  Memorizing
//
//  Created by 이종현 on 7/2/24.
//

import FirebaseCore
import SwiftUI
  
@main
struct MemorizingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}
