//
//  UIApplicationExtensions.swift
//  Dcard Prototype
//
//  Created by aipeople on 7/11/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 Nulu. All rights reserved.
//

import UIKit


// MARK: - View Controller & View
extension UIApplication {
    
    
    // MARK: - Class methods
    static var rootViewController: RootViewController {
        get {
            return UIApplication.sharedApplication().rootViewController as! RootViewController
        }
    }
    
    static var mainWindow: UIWindow {
        get {
            return UIApplication.sharedApplication().mainWindow
        }
    }
    
    static var topViewController: UIViewController {
        get {
            return UIApplication.sharedApplication().topViewController
        }
    }
    
    
    // MARK: - Methods
    var rootViewController: UIViewController? {
        guard let delegate = delegate else {
            return nil
        }
        guard let window = delegate.window else {
            return nil
        }
        return window?.rootViewController
    }
    
    var mainWindow: UIWindow {
        get {
            return self.windows.first!
        }
    }
    
    var topViewController: UIViewController {
        get {
            return self.topViewControllerFromController(self.rootViewController!)
        }
    }
    
    
    func topViewControllerFromController(currentViewController: UIViewController) -> UIViewController {
        
        if  let currentViewController = currentViewController as? UINavigationController,
            let topViewController = currentViewController.topViewController {
            return self.topViewControllerFromController(topViewController)
        } else if
            let currentViewController = currentViewController as? UITabBarController,
            let selectedViewController = currentViewController.selectedViewController {
            return self.topViewControllerFromController(selectedViewController)
        } else if currentViewController.presentedViewController != nil {
            return self.topViewControllerFromController(currentViewController.presentedViewController!)
        } else {
            return currentViewController
        }
    }
}
