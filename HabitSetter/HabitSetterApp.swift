//
//  HabitSetterApp.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-21.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct HabitSetterApp: App {
    
    @StateObject var habitsVM = HabitsViewModel() // Initialized here
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitsVM) // Pass the initialized ViewModel
        }
    }
}

extension Notification.Name {
    static let didUpdateUserId = Notification.Name("didUpdateUserId")
    static let didLogOut = Notification.Name("didLogOut")
}

