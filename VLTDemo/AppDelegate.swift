//
//  AppDelegate.swift
//  VLTDemo
//
//  Created by Verizon Location Technology
//  Copyright © 2020 Verizon Location Technology. All rights reserved.
//

import UIKit

/// Product API key is kept globally and needed to initialize or use specific functionality (set in AppDelegate)
var apiKey: String = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK - Private Members
    /// typealias to string literals for this file
    fileprivate typealias literals = VLTLiterals.AssetNameLiterals
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /// Please enter your VLT API key as the value for key `VLTApiKey` in the Info.plist
        if let path = Bundle.main.path(forResource: "Info", ofType: ".plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let vltApiKey = dict[literals.apiKeyLocation] as? String {
            apiKey = vltApiKey
        }
        
        /// Application theming
        if let primaryColor = UIColor(named: literals.primaryColor),
            let secondaryColor = UIColor(named: literals.secondaryColor) {
            let titleFont = UIFont.boldSystemFont(ofSize: 20)
            let backButtonFont = UIFont.systemFont(ofSize: 12)
            
            let appearance = UINavigationBar.appearance()
            let standardAppearance = UINavigationBarAppearance()
            
            standardAppearance.backgroundColor = primaryColor
            standardAppearance.titleTextAttributes = [.font: titleFont, .foregroundColor: secondaryColor]
            standardAppearance.backButtonAppearance.normal.titleTextAttributes = [.font: backButtonFont]
            standardAppearance.buttonAppearance.normal.titleTextAttributes = [.font: backButtonFont]
            
            if let originalImage = UIImage(systemName: literals.leftChevronImage), let backImage = originalImage.cgImage {
                let scaledImage = UIImage(cgImage: backImage, scale: originalImage.scale * 0.95, orientation: originalImage.imageOrientation)
                standardAppearance.setBackIndicatorImage(scaledImage, transitionMaskImage: scaledImage)
            }
            
            appearance.standardAppearance = standardAppearance
        }
            
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

