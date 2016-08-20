//
//  NoPaddingTextView.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


class NoPaddingTextView : UITextView, UITextViewDelegate {
    
    // Properties
    // UI
    private(set) var placeholderLabel = UILabel()
    
    override var textContainerInset: UIEdgeInsets {
        set {
            var inset = newValue
            inset.left   -= 5
            inset.right  -= 5
            super.textContainerInset = inset
            self.placeholderRightConstraint.constant = -newValue.right
            self.placeholderLeftConstraint.constant = newValue.left
            self.placeholderTopConstraint.constant = newValue.top
        }
        get {
            var inset = super.textContainerInset
            inset.left   += 5
            inset.right  += 5
            return inset
        }
    }
    
    override var text: String! {
        didSet {
            self.updatePlaceholderState()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            self.updatePlaceholderState()
        }
    }
    
    // Data
    var fixEnabled = false
    private var classDelegate: UITextViewDelegate?
    override var delegate: UITextViewDelegate? {
        set {self.classDelegate = newValue}
        get {return super.delegate}
    }
    
    var placeholder: String? {
        set {self.placeholderLabel.text = newValue}
        get {return self.placeholderLabel.text}
    }
    
    private var placeholderRightConstraint: NSLayoutConstraint!
    private var placeholderLeftConstraint: NSLayoutConstraint!
    private var placeholderTopConstraint: NSLayoutConstraint!
    
    
    
    // MARK: - Life Cycle
    init() {
        
        super.init(frame: CGRectZero, textContainer: nil)
        
        // Setup Constraints
        self.addSubview(self.placeholderLabel)
        constrain(self.placeholderLabel) { (placeholder) -> () in
            
            self.placeholderRightConstraint =
                ( placeholder.right == placeholder.superview!.right )
            self.placeholderLeftConstraint =
                ( placeholder.left == placeholder.superview!.left )
            self.placeholderTopConstraint  =
                ( placeholder.top  == placeholder.superview!.top )
        }
        
        
        // Setup Views
        super.delegate = self
        self.backgroundColor = UIColor.clearColor()
        self.textContainerInset = UIEdgeInsetsZero
        
        self.placeholderLabel.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        guard self.fixEnabled else {return}
        
        if  self.frame.height >= self.contentSize.height {
            self.contentOffset.y = -self.contentInset.top
        } else if !self.decelerating && !self.dragging {
            let offsetY = self.contentOffset.y
            self.contentOffset.y = min(
                offsetY,
                self.contentSize.height - self.frame.height + self.contentInset.bottom
            )
        }
        self.layer.removeAllAnimations()
    }
    
    
    // MARK: - Methods
    override func caretRectForPosition(position: UITextPosition) -> CGRect {
        
        var originalRect = super.caretRectForPosition(position)
        var styling = self.textStylingAtPosition(position, inDirection: .Backward);
        if let font = styling?[NSFontAttributeName] as? UIFont {
            originalRect.size.height = font.lineHeight
        }
        
        return originalRect
    }
    
    
    // MARK: - Event
    func updatePlaceholderState() {
        
        self.placeholderLabel.hidden = self.text.characters.count > 0
    }
    
    
    // MARK: - Text View Delegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        return classDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        return classDelegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        classDelegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        classDelegate?.textViewDidEndEditing?(textView)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return classDelegate?.textView?(textView, shouldChangeTextInRange: range, replacementText: text) ?? true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        self.updatePlaceholderState()
        classDelegate?.textViewDidChange?(textView)
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        classDelegate?.textViewDidChangeSelection?(textView)
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        return classDelegate?.textView?(textView, shouldInteractWithURL: URL, inRange: characterRange) ?? true
    }
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        
        return classDelegate?.textView?(textView, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange) ?? false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        classDelegate?.scrollViewDidScroll?(scrollView)
    }
}










