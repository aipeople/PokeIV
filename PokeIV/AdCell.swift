//
//  AdCell.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//


import UIKit
import Cartography
import Shimmer
import FBAudienceNetwork


class AdCell: UITableViewCell {
    
    // MARK: - Properties
    // UI
    let container    = UIView()
    let bannerView   = UIImageView()
    let iconView     = UIImageView()
    let titleLabel   = UILabel()
    let bodyLabel    = UILabel()
    let actionButton = UIButton(type: .System)
    let adLabel = UILabel()
    
    // Data
    weak var nativeAd : FBNativeAd? {
        didSet {
            if self.nativeAd != oldValue {
                self.displayNativeAd(self.nativeAd)
            }
        }
    }
    
    
    // MARK: - Life Cycle
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Setup Constraints
        self.contentView.addSubview(self.container)
        constrain(self.container) { (view) in
            view.center  == view.superview!.center
            view.width   == view.superview!.width  - 20
            view.height  == view.superview!.height - 10
        }
        
        self.container.addSubview(self.bannerView)
        constrain(self.bannerView) { (view) in
            view.left   == view.superview!.left
            view.right  == view.superview!.right
            view.top    == view.superview!.top
            view.bottom == view.superview!.bottom - 60
        }
        
        self.container.addSubview(self.iconView)
        constrain(self.iconView) { (view) in
            view.left   == view.superview!.left + 8
            view.bottom == view.superview!.bottom - 8
            view.width  == 44
            view.height == 44
        }
        
        self.container.addSubview(self.titleLabel)
        constrain(self.titleLabel) { (view) in
            view.left  == view.superview!.left + 58
            view.right == view.superview!.right - 124
            view.bottom == view.superview!.bottom - 32
        }
        
        self.container.addSubview(self.bodyLabel)
        constrain(self.bodyLabel) { (view) in
            view.left  == view.superview!.left + 58
            view.right == view.superview!.right - 124
            view.bottom == view.superview!.bottom - 12
        }
        
        self.container.addSubview(self.actionButton)
        constrain(self.actionButton) { (view) in
            view.right  == view.superview!.right  - 8
            view.bottom == view.superview!.bottom - 8
            view.width  == 110
            view.height == 44
        }
        
        self.container.addSubview(self.adLabel)
        constrain(self.adLabel) { (view) in
            view.center == view.superview!.center
        }
        
        // Setup views
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle  = .None
        
        self.container.backgroundColor = App.Color.Background.Level2
        self.container.layer.cornerRadius = 2
        self.container.clipsToBounds = true
        
        self.titleLabel.textColor = App.Color.Text.Normal
        self.titleLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        
        self.bodyLabel.textColor = App.Color.Text.SemiLight
        self.bodyLabel.font = UIFont.systemFontOfSize(15)
        
        self.bannerView.contentMode   = .ScaleAspectFill
        self.bannerView.clipsToBounds = true
        
        self.actionButton.setTitleColor(App.Color.Background.Level1, forState: .Normal)
        self.actionButton.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        self.actionButton.hidden = true
        
        self.adLabel.text = NSLocalizedString("Ad.", comment: "advertisement place holder")
        self.adLabel.textColor = UIColor(white: 0, alpha: 0.1)
        self.adLabel.font = UIFont.systemFontOfSize(92, weight: UIFontWeightBold)
        
        let bgImage = UIImage.imageWithSize(
            CGSize(width: 10, height: 10), color: App.Color.Main, cornerRadius: 4
        ).resizableImageWithCapInsets(UIEdgeInsetsMake(4, 4, 4, 4))
        self.actionButton.setBackgroundImage(bgImage, forState: .Normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func displayNativeAd(nativeAd: FBNativeAd?) {
        
        if  let nativeAd = nativeAd {
            
            nativeAd.coverImage?.loadImageAsyncWithBlock({ (image) in
                self.bannerView.image = image
            })
            
            nativeAd.icon?.loadImageAsyncWithBlock({ (image) in
                self.iconView.image = image
            })
            
            self.titleLabel.text = nativeAd.title
            self.bodyLabel.text  = nativeAd.body
            self.actionButton.setTitle(nativeAd.callToAction, forState: .Normal)
            self.actionButton.hidden = false
            self.adLabel.hidden = true
            
            nativeAd.registerViewForInteraction(self.container, withViewController: UIApplication.rootViewController)
            
        } else {
            
            self.actionButton.hidden = true
            self.adLabel.hidden   = false
            self.bannerView.image = nil
            self.iconView.image   = nil
            self.titleLabel.text  = nil
            self.bodyLabel.text   = nil
        }
        
    }
}
