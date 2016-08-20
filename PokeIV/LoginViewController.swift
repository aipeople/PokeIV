//
//  ViewController.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


extension LoginViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        
        return .Slide
    }
}


class LoginViewController: UIViewController {
    
    // MARK: - Properties
    // UI
    let logoLabel = UILabel()
    let GPSButton = UIButton(type: .System)
    let PTCButton = UIButton(type: .System)
    let headView  = UIImageView(image: UIImage(named: "image_symbol"))
    let arrowView = UIImageView(image: UIImage(named: "image_arrow"))
    
    let usernameField = UITextField()
    let passwordField = UITextField()
    
    let loginButton = UIButton(type: .System)
    let indicator   = UIActivityIndicatorView()
    
    let declareLabel = UILabel()
    
    // Data
    var loading = false {
        didSet {
            self.loadingStatusChanged()
        }
    }
    private var loginToken = 0.0
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup constraints
        self.view.addSubview(self.headView)
        constrain(self.headView) { (view) in
            view.centerX == view.superview!.centerX
            view.top == view.superview!.top
        }
        
        self.view.addSubview(self.logoLabel)
        constrain(self.logoLabel) { (view) in
            view.centerX == view.superview!.centerX
            view.top == view.superview!.top + 134
        }
        
        self.view.addSubview(self.GPSButton)
        constrain(self.GPSButton) { (view) in
            view.centerX == view.superview!.centerX - 25
            view.centerY == view.superview!.centerY - 72.5
            view.width   == 50
            view.height  == 50
        }
        
        self.view.addSubview(self.PTCButton)
        constrain(self.PTCButton) { (view) in
            view.centerX == view.superview!.centerX + 25
            view.centerY == view.superview!.centerY - 72.5
            view.width   == 50
            view.height  == 50
        }
        
        self.view.addSubview(self.arrowView)
        constrain(self.arrowView) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY - 48.5
        }
        
        self.view.addSubview(self.usernameField)
        constrain(self.usernameField) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY - 24.5
            view.width   == 240
            view.height  == 32
        }
        
        self.view.addSubview(self.passwordField)
        constrain(self.passwordField) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY + 24.5
            view.width   == 240
            view.height  == 32
        }
        
        self.view.addSubview(self.loginButton)
        constrain(self.loginButton) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY + 82
            view.width   == 240
            view.height  == 44
        }
        
        self.view.addSubview(self.indicator)
        constrain(self.loginButton, self.indicator) { (button, view) in
            view.center == button.center
        }
        
        self.view.addSubview(self.declareLabel)
        constrain(self.declareLabel) { (view) in
            view.centerX == view.superview!.centerX
            view.bottom == view.superview!.bottom - 8
        }
        
        
        // Setup Views
        self.view.backgroundColor = App.Color.Background.Level1
        
        self.headView.tintColor  = App.Color.Main
        self.arrowView.tintColor = App.Color.Main
        
        self.headView.userInteractionEnabled = false
        self.arrowView.userInteractionEnabled = false
        
        self.logoLabel.text = "PokéIVs"
        self.logoLabel.textColor = App.Color.Main
        self.logoLabel.font = UIFont.systemFontOfSize(26, weight: UIFontWeightMedium)
        
        self.GPSButton.setImage(UIImage(named: "icon_google"), forState: .Normal)
        self.PTCButton.setImage(UIImage(named: "icon_ptc"),    forState: .Normal)
        self.PTCButton.alpha = 0.25
        
        self.GPSButton.addTarget(self,
            action: #selector(handleLoginTypeButtonOnTap(_:)),
            forControlEvents: .TouchUpInside
        )
        self.PTCButton.addTarget(self,
            action: #selector(handleLoginTypeButtonOnTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        self.usernameField.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        self.passwordField.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        self.usernameField.layer.cornerRadius = 4
        self.passwordField.layer.cornerRadius = 4
        
        self.usernameField.textAlignment = .Center
        self.passwordField.textAlignment = .Center
        
        self.usernameField.autocorrectionType = .No
        self.usernameField.autocapitalizationType = .None
        self.passwordField.secureTextEntry = true
        self.passwordField.clearsOnBeginEditing = true
        
        self.usernameField.addTarget(self, action: #selector(handleEditingChanged(_:)), forControlEvents: .EditingChanged)
        self.passwordField.addTarget(self, action: #selector(handleEditingChanged(_:)), forControlEvents: .EditingChanged)
        
        let holderAttrs = [
            NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.35),
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
        
        self.usernameField.attributedPlaceholder =
            NSAttributedString(
                string: NSLocalizedString("email", comment: "placeholder"),
                attributes: holderAttrs
            )
        
        self.passwordField.attributedPlaceholder =
            NSAttributedString(
                string: NSLocalizedString("password", comment: "placeholder"),
                attributes: holderAttrs
            )
        
        let typingAttrs = [
            NSForegroundColorAttributeName: App.Color.Text.Normal,
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
        
        self.usernameField.typingAttributes = typingAttrs
        self.passwordField.typingAttributes = typingAttrs
        
        let title = NSLocalizedString("LOGIN", comment: "login button title")
        self.loginButton.setTitle(title, forState: .Normal)
        self.loginButton.setTitleColor(App.Color.Background.Level1, forState: .Normal)
        self.loginButton.titleLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightSemibold)
        self.loginButton.enabled = false
        
        let bgImage = UIImage.imageWithSize(
            CGSize(width: 10, height: 10), color: App.Color.Main, cornerRadius: 4
        ).resizableImageWithCapInsets(UIEdgeInsetsMake(4, 4, 4, 4))
        self.loginButton.setBackgroundImage(bgImage, forState: .Normal)
        
        let disabledBGImage = UIImage.imageWithSize(
            CGSize(width: 10, height: 10), color: App.Color.Main.colorWithAlphaComponent(0.25), cornerRadius: 4
            ).resizableImageWithCapInsets(UIEdgeInsetsMake(4, 4, 4, 4))
        self.loginButton.setBackgroundImage(disabledBGImage, forState: .Disabled)
        self.loginButton.addTarget(self,
            action: #selector(handleLoginButtonOnTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        self.indicator.color = App.Color.Background.Level1
        self.indicator.hidesWhenStopped = true
        
        self.declareLabel.text =
            NSLocalizedString("Resource:\ngithub.com/aipeople/PokeIV", comment: "source declaration")
        self.declareLabel.textColor = App.Color.Text.Disable
        self.declareLabel.textAlignment = .Center
        self.declareLabel.numberOfLines = 0
        self.declareLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        
        
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelfOnTap(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.updateArrowLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.passwordField.text = ""
        self.loading = false
    }
    
    
    // MARK: - Methods
    func updateArrowLayout() {
        
        var transX = -25 as CGFloat
        if self.PTCButton.alpha >= 1.0 {
            transX = 25
        }
        self.arrowView.transform = CGAffineTransformMakeTranslation(transX, 0)
    }
    
    func loadingStatusChanged() {
        
        if self.loading {
            
            self.view.userInteractionEnabled = false
            self.usernameField.resignFirstResponder()
            self.passwordField.resignFirstResponder()
            
            self.loginButton.setTitle("", forState: .Normal)
            self.indicator.startAnimating()
            
        } else {
            
            self.view.userInteractionEnabled = true
            
            let title = NSLocalizedString("LOGIN", comment: "login button title")
            self.loginButton.setTitle(title, forState: .Normal)
            self.indicator.stopAnimating()
        }
    }
    
    
    // MARK: - Events
    func handleSelfOnTap(sender: UITapGestureRecognizer) {
        
        self.usernameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }
    
    func handleLoginTypeButtonOnTap(sender: UIButton) {
        
        self.GPSButton.alpha = self.GPSButton == sender ? 1.0 : 0.25
        self.PTCButton.alpha = self.PTCButton == sender ? 1.0 : 0.25
        
        let holderAttrs = [
            NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.35),
            NSFontAttributeName: UIFont.systemFontOfSize(16)
        ]
        
        self.usernameField.attributedPlaceholder =
            NSAttributedString(
                string: self.GPSButton == sender ?
                    NSLocalizedString("email", comment: "placeholder") :
                    NSLocalizedString("username", comment: "placeholder"),
                attributes: holderAttrs
        )
        
        self.usernameField.keyboardType =
            self.GPSButton == sender ? .EmailAddress : .ASCIICapable
        
        UIView.animateWithDuration(0.4,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            options: .BeginFromCurrentState,
            animations: {
                self.updateArrowLayout()
            }, completion: nil)
    }
    
    func handleLoginButtonOnTap(sender: UIButton) {
        
        self.loading = true
        
        let handler = { (erorr: NSError?) in
            
            self.loginToken = 0.0
            if let error = erorr {
                
                self.loading = false
                
                let title = NSLocalizedString("Error", comment: "message title")
                PopoverView.popMessageWithTitle(title, message: error.localizedDescription)
                
            } else {
                
                UIApplication.rootViewController.switchToViewerState(true)
            }
        }
        
        if  let username = self.usernameField.text,
            let password = self.passwordField.text {
            
            if self.GPSButton.alpha >= 1.0 {
                PokeManager.defaultManager.loginWithGmail(username, password: password, handler: handler)
            } else {
                PokeManager.defaultManager.loginWithUserName(username, password: password, handler: handler)
            }
        } else {
            
            handler(Error.Code.Login.nserror())
        }
        
        // Timeout handler
        let loginToken = NSDate().timeIntervalSince1970
        self.loginToken = loginToken
        
        Control.delay(10) { 
            if loginToken == self.loginToken {
                PokeManager.defaultManager.loginHandler = nil
                self.loading = false
                
                let error = Error.Code.Connection.nserror()
                let title = NSLocalizedString("Error", comment: "message title")
                PopoverView.popMessageWithTitle(title, message: error.localizedDescription)
            }
        }
    }
    
    func handleEditingChanged(sender: UITextField) {
        
        self.loginButton.enabled =
            self.usernameField.text?.characters.count > 0 &&
            self.passwordField.text?.characters.count > 0
    }
}












