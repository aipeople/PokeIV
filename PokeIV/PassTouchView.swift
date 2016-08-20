//
//  PassTouchView.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit

class PassTouchView : UIView {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var view = super.hitTest(point, withEvent: event)
        if  view == self {
            view = nil;
        }
        return view;
    }
}
