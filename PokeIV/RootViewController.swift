//
//  RootViewController.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography
import pop


extension RootViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        
        return false
        /*
        return self.loginViewController.view.hidden ?
            self.pokemonViewController.prefersStatusBarHidden() :
            self.loginViewController.prefersStatusBarHidden()*/
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return .LightContent
        /*
        return self.loginViewController.view.hidden ?
            self.pokemonViewController.preferredStatusBarStyle() :
            self.loginViewController.preferredStatusBarStyle()*/
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        
        return .Slide
        /*
        return self.loginViewController.view.hidden ?
            self.pokemonViewController.preferredStatusBarUpdateAnimation() :
            self.loginViewController.preferredStatusBarUpdateAnimation()*/
    }
}


class RootViewController : UIViewController {
    
    var loginViewController = LoginViewController()
    var pokemonViewController = PokemonsViewController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addViewController(self.loginViewController)
        self.addViewController(self.pokemonViewController)
        
        if PokeManager.defaultManager.logined {
            self.switchToViewerState(false)
        } else {
            self.switchToLoginState(false)
        }
    }
    
    
    // MARK: - Methods
    func addViewController(viewController: UIViewController) {
        
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        constrain(viewController.view) { (view) in
            view.edges == view.superview!.edges
        }
        viewController.didMoveToParentViewController(self)
    }
    
    func switchToLoginState(animated: Bool) {
        
        if animated {
            
            if self.loginViewController.view.hidden {
                self.flip()
            }
        } else {
            self.loginViewController.view.hidden = false
            self.pokemonViewController.view.hidden = true
        }
    }
    
    func switchToViewerState(animated: Bool) {
        
        if animated {
            
            if self.pokemonViewController.view.hidden {
                self.flip()
            }
            
        } else {
            self.loginViewController.view.hidden = true
            self.pokemonViewController.view.hidden = false
        }
    }
    
    func flip() {
        
        self.view.userInteractionEnabled = false
        
        var updated  = false
        let property =
            POPAnimatableProperty.propertyWithName("container") { (property) -> Void in
                
                property.writeBlock = { (obj, values) -> Void in
                    
                    let progress  = values[0]
                    let scale = 0.85 + (fabs(0.5 - progress) * 2 * 0.15)
                    
                    var transform = CATransform3DIdentity
                    transform.m34 = -0.001
                    transform = CATransform3DScale(transform, scale, scale, 1.0)
                    
                    if progress < 0.5 {
                        transform = CATransform3DRotate(transform, -progress * CGFloat(M_PI), 0, 1, 0)
                    } else {
                        transform = CATransform3DRotate(transform, -(progress - 1.0) * CGFloat(M_PI), 0, 1, 0)
                        
                        if !updated {
                            self.loginViewController.view.hidden = !self.loginViewController.view.hidden
                            self.pokemonViewController.view.hidden = !self.pokemonViewController.view.hidden
                            updated = true
                            
                            // Status bar
                            UIView.animateWithDuration(0.25) {
                                self.setNeedsStatusBarAppearanceUpdate()
                                self.view.window?.layoutIfNeeded()
                            }
                            
                            if self.loginViewController.view.hidden {
                                self.pokemonViewController.viewWillAppear(true)
                            } else {
                                self.loginViewController.viewWillAppear(true)
                            }
                        }
                    }
                    self.view.layer.transform = transform
                }
                
                property.threshold = 0.01
        }
        
        let anim = POPBasicAnimation.easeOutAnimation()
        anim.property  = property as! POPAnimatableProperty
        anim.fromValue = 0
        anim.toValue   = 1
        anim.duration  = 0.5
        anim.completionBlock  = {(finished) in
            
            self.view.userInteractionEnabled = true
        }
        
        self.view.pop_removeAnimationForKey("container")
        self.view.pop_addAnimation(anim, forKey: "container")
    }
}










