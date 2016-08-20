//
//  PopoverView.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


enum PopoverStyle {
    
    case Center
    case FromBottom
    case FromTop
}


extension UIView {
    
    var popoverView: PopoverView? {
        get {
            var parentView: UIView? = self
            while parentView != nil {
                if let popoverView = parentView as? PopoverView {
                    return popoverView
                }
                parentView = parentView?.superview
            }
            return nil
        }
    }
}


typealias PopoverViewCallBack = (popoverView:PopoverView) -> ()
struct Popover {
    
    static func asActionSheet(height height: CGFloat? = 216, padding: CGFloat = 8, avoidChangeStyle: Bool = false) -> PopoverViewCallBack {
        
        return {(popoverView) in
            
            if !avoidChangeStyle {
                popoverView.popoverStyle = .FromBottom
            }
            
            constrain(popoverView.contentView, block: { (content) -> () in
                
                content.width   == content.superview!.width - (padding * 2)
                content.bottom  == content.superview!.bottom - padding
                content.centerX == content.superview!.centerX
            })
            
            if let height = height {
                
                constrain(popoverView.contentView, block: { (content) -> () in
                    content.height  == height
                })
            }
        }
    }
    
    static func inCenterDamping(width: CGFloat? = nil, height: CGFloat? = nil) -> PopoverViewCallBack {
        
        return {(popoverView) in
            
            popoverView.popoverStyle = .Center
            popoverView.animationDamping = 0.5
            popoverView.animationSpeed   = 0.5
            
            constrain(popoverView.contentView, block: { (content) -> () in
                content.center == content.superview!.center
            })
            
            if let width = width {
                
                constrain(popoverView.contentView, block: { (content) -> () in
                    content.width == width
                })
            }
            
            if let height = height {
                
                constrain(popoverView.contentView, block: { (content) -> () in
                    content.height == height
                })
            }
        }
    }
    
    static func inCenter(width: CGFloat? = nil, height: CGFloat? = nil) -> PopoverViewCallBack {
        
        return {(popoverView) in
            
            constrain(popoverView.contentView, block: { (content) -> () in
                content.center == content.superview!.center
            })
            
            if let width = width {
                
                constrain(popoverView.contentView, block: { (content) -> () in
                    content.width == width
                })
            }
            
            if let height = height {
                
                constrain(popoverView.contentView, block: { (content) -> () in
                    content.height == height
                })
            }
        }
    }
    
    static func withInsets(insets: UIEdgeInsets = UIEdgeInsetsZero) -> PopoverViewCallBack {
        
        return {(popoverView) in
            
            constrain(popoverView.contentView, block: { (content) -> () in
                
                content.left   == content.superview!.left   + insets.left
                content.right  == content.superview!.right  - insets.right
                content.top    == content.superview!.top    + insets.top
                content.bottom == content.superview!.bottom - insets.bottom
            })
        }
    }
    
    static func beginFromView(view: UIView?) -> PopoverViewCallBack? {
    
        if let view = view {
        
            return {[weak view](popoverView) in
                
                if let view = view {
                
                    let contentView = popoverView.contentView
                    contentView.transform = CGAffineTransformIdentity
                    
                    let viewCenter  = contentView.convertPoint(view.center, fromView: view.superview)
                    let centerDelta = CGPoint(x: viewCenter.x - contentView.frame.width * 0.5,
                                              y: viewCenter.y - contentView.frame.height * 0.5)
                    let scaleDelta  = CGSize(width:  view.frame.width  / contentView.frame.width,
                                             height: view.frame.height / contentView.frame.height)
                    
                    var trans = CGAffineTransformIdentity
                    trans = CGAffineTransformTranslate(trans, centerDelta.x, centerDelta.y)
                    trans = CGAffineTransformScale(trans, scaleDelta.width, scaleDelta.height)
                    contentView.transform = trans
                }
            }
        }
        return nil
    }
}


typealias PopoverViewShouldDismissCallback = ((popoverView: PopoverView) -> Bool)

class PopoverView : TouchSensingView {
    
    // MARK: - Properties
    var contentView: UIView!
    var containerView = PassTouchView()
    var maskColor     = UIColor(white: 0.2, alpha: 0.75)
    var popoverStyle  = PopoverStyle.Center
    var dismissWhenTouchOutside = true
    var resizeWithKeybaord      = true
    var shouldDismissCallback: PopoverViewShouldDismissCallback = { _ in
        return true
    }
    
    var animationDamping: CGFloat = 1.0
    var animationSpeed: CGFloat   = 0.0
    var presentCallback: PopoverViewCallBack?
    weak var bottomConstraint: NSLayoutConstraint?
    
    
    // MARK: - Life Cycle
    init(contentView: UIView) {
        
        self.contentView = contentView
        super.init()
        
        // Setup Constraints
        self.addSubview(self.containerView)
        constrain(self.containerView) { (view) in
            
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            
            self.bottomConstraint =
                view.bottom == view.superview!.bottom
        }
        
        // Setup Views
        self.backgroundColor = UIColor.clearColor()
        
        self.ignoredViews.append(contentView)
        self.sensingBeforeTouchEvent = false
        self.touchEndedCallBack = {[weak self] _ in
        
            if let popoverView = self {
                if popoverView.dismissWhenTouchOutside {
                    popoverView.dismiss()
                }
            }
        }
        
        
        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(PopoverView.handleKeyboardWillChangeFrame(_:)),
            name: UIKeyboardWillChangeFrameNotification,
            object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - UI Methods
    func setupContentView() {
        
        switch self.popoverStyle {
            
        case .FromBottom :
            let transY = self.bounds.height - self.contentView.frame.origin.y
            self.contentView.transform = CGAffineTransformMakeTranslation(0, transY)
            
        case .FromTop :
            let transY = -(self.bounds.height - self.contentView.frame.origin.y)
            self.contentView.transform = CGAffineTransformMakeTranslation(0, transY)
            
        default:
            let width = contentView.bounds.width > 0 ? contentView.bounds.width : 40
            let scale = min((width - 40) / width, 0.9)
            self.contentView.transform = CGAffineTransformMakeScale(scale, scale)
            self.contentView.alpha = 0
        }
    }
    
    func durationWithStyle(duration: Double) -> Double {
        
        switch self.popoverStyle {
            
        case .Center:
            return self.animationDamping == 0 ? duration * 0.75 : duration
        default:
            return duration
        }
    }
    
    
    // MARK: - Events
    func present(
        setupConstraint: PopoverViewCallBack,
        didPresent:  PopoverViewCallBack? = nil) {
            
        self.presentWithDuration(0.5, setupConstraint: setupConstraint, willPresent: nil, willAnimate: nil, didPresent: didPresent)
    }
    
    func presentWithDuration(
        duration: Double,
        setupConstraint: PopoverViewCallBack? = nil,
        willPresent: PopoverViewCallBack? = nil,
        willAnimate: PopoverViewCallBack? = nil,
        didPresent:  PopoverViewCallBack? = nil) {
        
        if let topView = UIApplication.mainWindow.subviews.last {
        
            // Add to top view
            topView.addSubview(self)
            constrain(self, block: { (view) -> () in
                view.edges == view.superview!.edges
            })
            
            // Add content view
            self.layoutIfNeeded()
            self.containerView.addSubview(self.contentView)
            setupConstraint?(popoverView: self)
            
            // Setup Transform
            self.contentView.layoutIfNeeded()
            self.setupContentView()
            
            
            // Present
            self.presentCallback = willPresent
            self.presentCallback?(popoverView: self)
            UIView.animateWithDuration(
                self.durationWithStyle(duration),
                delay: 0,
                usingSpringWithDamping: self.animationDamping,
                initialSpringVelocity: self.animationSpeed,
                options: .BeginFromCurrentState,
                animations: { () -> Void in
                
                    self.contentView.transform = CGAffineTransformIdentity
                    self.contentView.alpha = 1
                    willAnimate?(popoverView: self)
                
                }, completion: { _ in
            
                    didPresent?(popoverView: self)
                })
            
            UIView.animateWithDuration(
                self.durationWithStyle(duration) * 0.8,
                delay: 0,
                options: .BeginFromCurrentState,
                animations: { () -> Void in
                
                self.backgroundColor   = self.maskColor
                
                }, completion: nil)
        }
    }
    
    func dismiss(didDismiss:  PopoverViewCallBack? = nil) {
        
        self.dismissWithDuration(0.3, willAnimate: nil, didDismiss: didDismiss)
    }
    
    func dismissWithDuration(
        duration: Double,
        willAnimate: PopoverViewCallBack? = nil,
        didDismiss:  PopoverViewCallBack? = nil) {
        
        if self.shouldDismissCallback(popoverView: self) {
            
            self.userInteractionEnabled = false
            UIView.animateWithDuration(
                self.durationWithStyle(duration),
                delay: 0,
                options: [.CurveEaseInOut, .BeginFromCurrentState],
                animations: { () -> Void in
                    
                    self.backgroundColor = UIColor.clearColor()
                    self.setupContentView()
                    self.presentCallback?(popoverView: self)
                    willAnimate?(popoverView: self)
                    
                }, completion: { _ in
                    
                    self.removeFromSuperview()
                    didDismiss?(popoverView: self)
            })
        }
    }
    
    func handleKeyboardWillChangeFrame(notification: NSNotification) {
        
        if resizeWithKeybaord {
        
            let frame    = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
            // Default options are [.LayoutSubviews, .AllowUserInteraction, .BeginFromCurrentState] = 7
            // However, .AllowUserInteraction may cause the editable view become first responder again immediately.
            // Cuz the final place of the editable view may overlapping with the touch point.
            //let option   = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey.nsstring] as! NSNumber).integerValue
            
            var delta = -frame.height
            if let window = self.window {
                delta = (frame.origin.y - window.frame.height)
            }
            
            UIView.animateWithDuration(duration,
                delay: 0,
                options: [.LayoutSubviews, .BeginFromCurrentState],
                animations: {
                
                    self.bottomConstraint?.constant = delta
                    self.layoutIfNeeded()
                    
                }, completion: nil)
        }
    }
}










