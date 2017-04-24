//
//  AppDelegate.swift
//  glassHouses
//
//  Created by Jonathon Day on 2/7/17.
//  Copyright © 2017 dayj. All rights reserved.
//

import UIKit
import UserNotifications
import Fabric
import Crashlytics
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var activityItemStore: ActivityItemStore!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        
        let webservice = Webservice()
        activityItemStore = ActivityItemStore(webservice: webservice)
        
        let fetchRequest: NSFetchRequest<Legislator> = Legislator.fetchRequest()
        let predicate = NSPredicate(format: "following == true")
        fetchRequest.predicate = predicate
        var fetchedLegislators: [Legislator]?
        ActivityItemStore.context.performAndWait {
            fetchedLegislators = try? fetchRequest.execute()
        }
        if let fetchedLegislators = fetchedLegislators,
            !fetchedLegislators.isEmpty {
            Environment.current.state = fetchedLegislators.first!.state
            let activityFeedVC: ActivityFeedController = {
                let vc = ActivityFeedController()
                vc.webservice = webservice
                vc.activityItemStore = activityItemStore
                vc.legislators = fetchedLegislators
                vc.title = "Legislator Activity"
                return vc
            }()
            let navController = UINavigationController(rootViewController: activityFeedVC)
            window!.rootViewController = navController
        } else {
            let onboardingVC = window!.rootViewController as! OnboardingViewController
            onboardingVC.webservice = webservice
            onboardingVC.activityItemStore = activityItemStore
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // this only gets hit when the app is open or the user opened the notification from the app
        guard let linkString = data["url"] as? String,
            let legislatorName = data["legislator"] as? String,
            let url = URL(string: linkString) else {
                return
        }
        let navVC = window!.rootViewController as! UINavigationController
        let activityFeedVC = navVC.topViewController as! ActivityFeedController
        activityFeedVC.performSegue(withIdentifier: "showNews", sender: url)
        
        var fetchedLegislator: [Legislator]?
        let fetchRequest: NSFetchRequest<Legislator> = Legislator.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(Legislator.fullName)) == '\(legislatorName)'")
        fetchRequest.predicate = predicate
        ActivityItemStore.context.performAndWait {
            fetchedLegislator = try? fetchRequest.execute()
        }

        guard let json = data["json"] as? [String: Any],
            let legislator = fetchedLegislator?.first else {
                return
        }
        
        let _ = Article.fromJSON(json, legislator: legislator, into: ActivityItemStore.context)
    }
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        // Save to user defaults
        UserDefaultsManager.setAPNSToken(deviceTokenString)
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        ActivityItemStore.save()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

