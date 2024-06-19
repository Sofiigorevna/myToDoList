//
//  SceneDelegate.swift
//  myToDoList
//
//  Created by 1234 on 17.06.2024.
//

import UIKit
import FirebaseCore
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let taskStore = TaskStore()
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        FirebaseApp.configure()
        
        if (Auth.auth().currentUser != nil) {
            let viewController = TasksViewController(style: .insetGrouped)
            let navigationController = UINavigationController(rootViewController: viewController)
            window?.rootViewController = navigationController
            viewController.taskStore = taskStore
            
        } else {
            let viewController = AuthViewController()
            self.window?.rootViewController = viewController
        }
        
        window?.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        TasksUtility.save(self.taskStore.tasks)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        TasksUtility.save(self.taskStore.tasks)
    }
}
