//
//  TouchSensingView.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit


class TouchSensingView : UIView  {
    
    // MARK : - Properties
    var touchOutSideCallBack: ((sensingView: TouchSensingView) -> ())?
    var touchEndedCallBack: ((sensingView: TouchSensingView) -> ())?
    
    var ignoredViews = [UIView]()
    var sensingBeforeTouchEvent = true
    
    private var isPassingTouch = false
    
    
    // MARK: - Life Cycle
    init() {
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    func isTouchsNeedToBePassedThrough(touches: Set<UITouch>) -> Bool {
        
        if self.ignoredViews.count <= 0 {
            
            return false
        }
        
        for touch in touches {
            for ignoredView in self.ignoredViews {
                
                let point = touch.locationInView(ignoredView)
                if !CGRectContainsPoint(ignoredView.bounds, point) {
                    return false
                }
            }
        }
        return true
    }
    
    
    // MARK: - Evnets
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let hitView = super.hitTest(point, withEvent: event)
        
        if hitView == self {
            
            for ignoredView in self.ignoredViews {
                
                let rect = self.convertRect(ignoredView.bounds, fromView: ignoredView)
                if CGRectContainsPoint(rect, point) {
                    return nil
                }
            }
            
            if self.sensingBeforeTouchEvent {
                
                self.touchOutSideCallBack?(sensingView: self)
                return nil
                
            } else {
                
                return self
            }
        }
        return hitView;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if self.isTouchsNeedToBePassedThrough(touches) {
            
            self.nextResponder()?.touchesBegan(touches, withEvent: event)
            self.isPassingTouch = true
            
        } else {
            self.isPassingTouch = false
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if self.isPassingTouch {
            self.nextResponder()?.touchesMoved(touches, withEvent: event)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if self.isPassingTouch {
            
            self.nextResponder()?.touchesEnded(touches, withEvent: event)
            
        } else {
            
            self.touchEndedCallBack?(sensingView: self)
        }
        self.isPassingTouch = false
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
        if self.isPassingTouch {
            
            self.nextResponder()?.touchesCancelled(touches, withEvent: event)
            
        } else {
            
            self.touchEndedCallBack?(sensingView: self)
        }
        self.isPassingTouch = false
    }
}









