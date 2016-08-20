//
//  LoadingCell.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//


import UIKit
import Cartography
import Shimmer


class LoadingCell: UITableViewCell {
    
    // MARK: - Properties
    let container     = UIView()
    let separator     = UIView()
    let shimmeringView  = FBShimmeringView()
    
    
    // MARK: - Life Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Setup constraints
        self.contentView.addSubview(self.container)
        constrain(self.container) { (view) in
            view.center  == view.superview!.center
            view.width   == view.superview!.width  - 20
            view.height  == view.superview!.height - 10
        }
        
        self.container.addSubview(self.separator)
        constrain(self.separator) { (view) in
            view.left   == view.superview!.left + 10
            view.right  == view.superview!.right - 10
            view.bottom == view.superview!.bottom - 71
            view.height == 1
        }
        
        self.container.addSubview(self.shimmeringView)
        
        
        // Setup views
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle  = .None
        
        self.container.backgroundColor = App.Color.Background.Level2
        self.container.layer.cornerRadius = 2
        
        self.separator.backgroundColor = UIColor(white: 0, alpha: 0.15)
        
        let image = UIImage(named: "image_cell_placeholder")
        let placeholderView = UIImageView(image: image)
        placeholderView.tintColor = App.Color.Text.Disable
        
        self.shimmeringView.frame = CGRect(
            origin: CGPoint(x: 10, y: 10),
            size: placeholderView.frame.size
        )
        self.shimmeringView.contentView = placeholderView;
        self.shimmeringView.shimmeringAnimationOpacity = 0.25
    }
    
    override func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        self.shimmeringView.shimmering = true;
    }
    
    override func removeFromSuperview() {
        
        super.removeFromSuperview()
        self.shimmeringView.shimmering = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
