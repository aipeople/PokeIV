//
//  UIButtonExtension.swift
//  PokeIV
//
//  Created by aipeople on 8/17/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit

struct BorderButtonData {
    
    var title: String
    var titleColor: UIColor
    var borderColor: UIColor
    
    init(title: String,
         titleColor: UIColor  = UIColor(white: 0.15, alpha: 1.0),
         borderColor: UIColor = UIColor(white: 0, alpha: 0.15)) {
        
        self.title       = title
        self.titleColor  = titleColor
        self.borderColor = borderColor
    }
}


extension UIButton {
    
    static func barButtonWithImage(image: UIImage?) -> UIButton {
        
        let button = self.init(type: .System)
        
        if let image = image {
            button.tintColor = UIColor(white: 0.35, alpha: 1.0)
            button.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        return button
    }
    
    static func borderButtonWithTitle(title: String?, titleColor: UIColor, borderColor: UIColor = UIColor(white: 0, alpha: 0.15)) -> UIButton {
        
        let button = self.init(type: .System)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(titleColor, forState: .Normal)
        button.setTitleColor(titleColor.colorWithAlphaComponent(0.25), forState: .Disabled)
        button.layer.borderWidth  = 0.5
        button.layer.borderColor  = borderColor.CGColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font   = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        
        return button
    }
    
    static func borderButtonWithImage(image: UIImage?, overlayColor: UIColor?, borderColor: UIColor = UIColor(white: 0, alpha: 0.15)) -> UIButton {
        
        let tintImage: UIImage?
        
        if let overlayColor = overlayColor {
            tintImage = image?.imageColoredWithColor(overlayColor)
        } else {
            tintImage = image
        }
        
        let button = self.init(type: .System)
        button.setImage(tintImage?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        button.layer.borderWidth  = 0.5
        button.layer.borderColor  = borderColor.CGColor
        button.layer.cornerRadius = 4
        button.titleLabel?.font   = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        
        return button
    }
}
