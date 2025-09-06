////
//  canvaApp.swift
//  canva
//
//  Created by Jerry Jin on 6/9/2025.
//

import SwiftUI
import UIKit
import FirebaseCore

//final class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
//    ) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//}
//
@main
struct YourApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup { RootTabView() }
  }
}
