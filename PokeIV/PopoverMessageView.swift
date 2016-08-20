//
//  PopoverMessageView.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


class PopoverMessageView : PopoverTemplateView {
    
    // MARK: - Properties
    // UI
    let topView    = UIView()
    let titleLabel = UILabel()
    let textView   = NoPaddingTextView()
    
    // Data
    var topViewHidden = false
    var titleHidden: Bool {
        set {
            self.titleLabel.hidden = newValue
            self.setNeedsLayout()
        }
        get {return self.titleLabel.hidden}
    }
    var title: String? {
        set {self.titleLabel.text = newValue}
        get {return self.titleLabel.text}
    }
    var text: String? {
        set {self.setupText(newValue)}
        get {return self.textView.text}
    }
    var textAlignment = NSTextAlignment.Center {
        didSet{
            self.setupText(self.text)
        }
    }
    
    var topSpacing: CGFloat = 30.0
    var topViewHeightConstraint:      NSLayoutConstraint!
    var titleBottomSpacingConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Life Cycle
    override init() {
        
        super.init()
        
        // Setup Constraints
        self.addSubview(self.topView)
        constrain(self.topView) { (view) -> () in
            
            self.topViewHeightConstraint =
            view.height  == 70
            view.top     == view.superview!.top
            view.centerX == view.superview!.centerX
            view.width   == view.superview!.width
        }
        
        self.topView.addSubview(self.titleLabel)
        constrain(self.titleLabel) { (title) -> () in
            
            self.titleBottomSpacingConstraint =
            title.bottom  == title.superview!.bottom - 20
            title.width   == title.superview!.width  - 40
            title.centerX == title.superview!.centerX
        }
        
        self.addSubview(self.textView)
        self.sendSubviewToBack(self.textView)
        constrain(self.textView) { (text) -> () in
            
            text.edges  == text.superview!.edges
        }
        
        constrain(self) { (view) -> () in
            
            self.heightConstraint =
            view.height == 124 ~ 750
            view.height <= (UIApplication.mainWindow.frame.height - 100)
        }
        
        // Setup Views
        self.topView.backgroundColor = UIColor(white: 0.9, alpha: 0.95)
        
        self.titleLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        self.titleLabel.textColor = UIColor(white: 0.15, alpha: 1.0)
        self.titleLabel.textAlignment = .Center
        self.titleLabel.numberOfLines = 0
        
        self.textView.editable   = false
        self.textView.selectable = false
        self.textView.textContainerInset.left  = 20
        self.textView.textContainerInset.right = 20
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        self.titleLabel.layoutIfNeeded()
        
        let topViewHeight = self.topSpacing + (self.titleHidden ? 0 : self.titleLabel.frame.height + 20)
        self.topViewHeightConstraint.constant      = topViewHeight
        self.textView.textContainerInset.top       = self.topViewHeightConstraint.constant
        self.textView.textContainerInset.bottom    = self.bottomBar.frame.height + 10
        self.textView.scrollIndicatorInsets.top    = self.textView.textContainerInset.top
        self.textView.scrollIndicatorInsets.bottom = self.textView.textContainerInset.bottom
        
        let viewSize = self.textView.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.max))
        self.heightConstraint.constant = viewSize.height
    }
    
    
    // MARK: - UI Methods
    func setupText(text: String?) {
        
        if let text = text {
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = self.textAlignment
            paragraph.lineSpacing = 8
            
            var attrs = [String: AnyObject]()
            attrs[NSParagraphStyleAttributeName] = paragraph
            attrs[NSFontAttributeName] = UIFont.systemFontOfSize(16)
            attrs[NSForegroundColorAttributeName] = UIColor(white: 0.35, alpha: 1.0)
            
            self.textView.attributedText = NSAttributedString(string: text, attributes: attrs)
            self.setNeedsLayout()
        }
    }
}


extension PopoverView {
    
    static func popMessageWithTitle(
        title: String? = nil,
        message: String,
        buttons: [BorderButtonData]? = nil,
        fromView: UIView? = nil,
        callback: PopoverViewSelectionCallBack? = nil) -> PopoverMessageView {
        
            let messageView = PopoverMessageView()
            messageView.buttonData     = buttons ?? [BorderButtonData(title: NSLocalizedString("OK", comment: "button title"))]
            messageView.text           = message
            messageView.selectCallback = callback
            
            if let title = title {
                messageView.title = title
            }
            
            let popoverView = PopoverView(contentView: messageView)
            popoverView.dismissWhenTouchOutside = false
            popoverView.presentWithDuration(0.5,
                setupConstraint: Popover.inCenter(UIApplication.mainWindow.frame.width - 40, height: nil),
                willPresent: Popover.beginFromView(fromView))
                
            return messageView
    }
}










