//
//  AppDelegate.swift
//  myToDoList
//
//  Created by 1234 on 17.06.2024.
//

import UIKit
import GoogleSignIn
import GoogleSignInSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
     return GIDSignIn.sharedInstance.handle(url)
    }
}
