 //
//  AppDelegate.swift
//  Flaintartist
//
//  Created by Kerby Jean on 1/1/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftyUserDefaults
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        userIsLoggingIn()
        
        if Defaults.hasKey(.email) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LogInNav")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ProfileNav")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = UIColor.flatSkyBlueColorDark()
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = false
        
        UITabBar.appearance().tintColor = UIColor.darkText
        self.window?.backgroundColor = UIColor.white
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        FIRMessaging.messaging().disconnect()
//    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //FBSDKAppEvents.activateApp()
        //connectToFCM()
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func logIn() {
        print("APP DELEGATE LOGIN")
        let tabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileNav") as! UINavigationController
        self.window?.rootViewController = tabBar
        self.window?.makeKeyAndVisible()
    }
    

    
    
    
    func userIsLoggingIn() {
        if let uid = Defaults[.key_uid] {
            let usersRef = Database.database().reference().child("users").child(uid)
            if !uid.isEmpty {
                usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "ProfileNav") as! UINavigationController
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                    usersRef.removeAllObservers()
                    
                    if ( snapshot.value is NSNull ) {
                        print(" CAN'T LOG IN: snapshot not found)")
                    }
                })
             }
          }
       }
    }
