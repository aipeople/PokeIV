//
//  UImageExtensions.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit


extension UIImage {
    
    static func imageWithSize(size: CGSize, color: UIColor, cornerRadius: CGFloat) -> UIImage {
        
        // General Declarations
        let radius = min(size.width * 0.5, size.height * 0.5, cornerRadius)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Rectangle Drawing
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        color.setFill()
        rectanglePath.fill()
        
        //Get Image
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
    func imageColoredWithColor(color: UIColor, blendMode: CGBlendMode = .Overlay) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        color.setFill()
        let rect = CGRect(origin: CGPointZero, size: self.size)
        
        self.drawInRect(rect)
        UIRectFillUsingBlendMode(rect, blendMode)
        self.drawInRect(rect, blendMode: blendMode, alpha: 1.0)
        
        if blendMode != .DestinationIn {
            var alpha: CGFloat = 0
            color.getRed(nil, green: nil, blue: nil, alpha: &alpha)
            self.drawInRect(rect, blendMode: .DestinationIn, alpha: alpha)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}









