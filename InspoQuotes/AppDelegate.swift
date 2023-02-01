//
//  AppDelegate.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let iapObserver = StoreObserver.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SKPaymentQueue.default().add(iapObserver)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SKPaymentQueue.default().remove(iapObserver)
    }
}

