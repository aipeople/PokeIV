//
//  PopoverTemplateView.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


typealias PopoverViewSelectionCallBack = (PopoverTemplateView, selectedIndex: Int) -> ()
class PopoverTemplateView : UIView {
    
    
    // MARK: - Properties
    let bottomBar     = UIView()
    var buttonData    = [BorderButtonData]() {didSet{self.setupButtons()}}
    private(set) var buttons = [UIButton]()
    
    var containerEdgesGroup: ConstraintGroup!
    private weak var firstButtonLeftConstraint: NSLayoutConstraint?
    private weak var lastButtonLeftConstraint: NSLayoutConstraint?
    
    // MARK: - Data
    var selectCallback: PopoverViewSelectionCallBack?
    
    // MARK: - Life Cycle
    init() {
        
        super.init(frame: CGRect.zero)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        // Setup Constraints
        self.addSubview(self.bottomBar)
        constrain(self.bottomBar) { (bar) -> () in
            
            bar.left   == bar.superview!.left
            bar.right  == bar.superview!.right
            bar.bottom == bar.superview!.bottom
            bar.height == 54
        }
        
        // Setup Constraints
        self.backgroundColor     = UIColor(white: 0.9, alpha: 1.0)
        self.layer.cornerRadius  = 4
        self.layer.masksToBounds = true
        self.bottomBar.backgroundColor = UIColor(white: 0.9, alpha: 1.0).colorWithAlphaComponent(0.95)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        let buttonNum = self.buttons.count
        let buttonsWidth = 150 * buttonNum + 10 * (buttonNum - 1)
        let spacing = (self.frame.width - CGFloat(buttonsWidth)) * 0.5
        if  spacing > 10 {
            
            self.firstButtonLeftConstraint?.constant = spacing
            self.lastButtonLeftConstraint?.constant  = -spacing
        }
    }
    
    
    // MARK: - UI Methods
    func setupButtons() {
        
        // Remove origin buttons
        for button in self.buttons {
            button.removeFromSuperview()
        }
        self.buttons.removeAll()
        
        
        // Setup new buttons
        var lastView: UIView?
        for data in self.buttonData {
            
            let button = UIButton.borderButtonWithTitle(data.title, titleColor: data.titleColor)
            button.layer.borderColor = data.borderColor.CGColor
            button.addTarget(self, action: #selector(PopoverTemplateView.handleButtonOnTap(_:)), forControlEvents: .TouchUpInside)
            self.buttons.append(button)
            self.bottomBar.addSubview(button)    
            
            if let lastView = lastView {
                constrain(button, lastView, block: { (button, view) -> () in
                    
                    button.height  == 34
                    button.width   == view.width ~ 750
                    button.centerY == button.superview!.centerY
                    
                    button.left    == view.right + 10
                })
            } else {
                constrain(button, block: { (button) -> () in
                    
                    button.height  == 34
                    button.width   <= 150
                    button.centerY == button.superview!.centerY
                    button.centerX == button.superview!.centerX   ~ 750
                    
                    self.firstButtonLeftConstraint =
                    button.left == button.superview!.left + 10 ~ 750
                })
            }
            lastView = button
        }
        if let lastView = lastView {
            constrain(lastView, block: { (view) -> () in
                self.lastButtonLeftConstraint =
                view.right == view.superview!.right - 10 ~ 750
            })
        }
    }
    
    
    // MARK: - Events
    func handleButtonOnTap(sender: UIButton) {
        
        if let index = self.buttons.indexOf(sender) {
            
            if let callback = self.selectCallback {
                callback(self, selectedIndex: index)
            } else {
                self.popoverView?.dismiss()
            }
        }
    }
    
}









