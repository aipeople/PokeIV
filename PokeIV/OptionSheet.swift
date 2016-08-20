//
//  OptionSheet.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


private let OptionSheetCellIdentifier = "CellIdentifier"

class OptionSheet<T> : UIView, UITableViewDataSource, UITableViewDelegate {
    
    typealias OptionSheetCloseCallBack = (sheet: OptionSheet) -> ()
    typealias OptionSheetOptionCallBack = (sheet: OptionSheet, option: T) -> String
    typealias OptionSheetSelectedCallBack = (sheet: OptionSheet, option: T) -> ()
    
    // MARK: - Properties
    // UI
    let topBar = UIView()
    let titleLabel = UILabel()
    let closeButton = UIButton.barButtonWithImage(UIImage(named: "icon_close"))
    let tableView = UITableView()
    
    // Data    var topBarHidden = false
    var title: String? {
        set {self.titleLabel.text = newValue}
        get {return self.titleLabel.text}
    }
    var options = [T]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var closeCallBack: OptionSheetCloseCallBack = { (sheet) in
        sheet.popoverView?.dismiss()
    }
    var displayParser: OptionSheetOptionCallBack = { (sheet, option) in
        
        if let string = option as? String {
            return string
        }
        return NSLocalizedString("未知的內容", comment: "Placeholder for unrecognized data source")
    }
    var selectedCallBack: OptionSheetSelectedCallBack?
    
    var barHeightConstraint: NSLayoutConstraint!
    var topBarHidden = false {
        didSet {
            self.topBar.hidden = self.topBarHidden
            self.barHeightConstraint.constant = self.topBarHidden ? 0 : 45
            self.tableView.contentInset.top   = self.barHeightConstraint.constant
        }
    }
    var cellHeight : CGFloat = 45 {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Life Cycle
    init(options: [T]) {
        
        self.options = options
        
        super.init(frame: CGRectZero)
        
        // Setup Constraints
        self.addSubview(self.topBar)
        constrain(self.topBar) { (bar) -> () in
            bar.top == bar.superview!.top
            bar.left == bar.superview!.left
            bar.right == bar.superview!.right
            
            self.barHeightConstraint = bar.height == 45
        }
        
        self.topBar.addSubview(self.titleLabel)
        constrain(self.titleLabel) { (title) -> () in
            title.center == title.superview!.center
        }
        
        self.topBar.addSubview(self.closeButton)
        constrain(self.closeButton) { (button) -> () in
            button.left    == button.superview!.left
            button.height  == button.superview!.height
            button.centerY == button.superview!.centerY
            button.width   == button.height
        }
        
        let separator = UIView()
        self.topBar.addSubview(separator)
        constrain(separator) { (separator) -> () in
            separator.left   == separator.superview!.left
            separator.right  == separator.superview!.right
            separator.bottom == separator.superview!.bottom + 0.5
            separator.height == 0.5
        }
        
        self.addSubview(self.tableView)
        self.sendSubviewToBack(self.tableView)
        constrain(self.tableView) { (table) -> () in
            table.edges == table.superview!.edges
        }
        
        // Setup Views
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        self.topBar.backgroundColor = UIColor(white: 0.9, alpha: 0.95)
        separator.backgroundColor   = UIColor(white: 0, alpha: 0.15)
        
        self.titleLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightMedium)
        self.titleLabel.textColor = UIColor(white: 0.15, alpha: 1.0)
        self.titleLabel.textAlignment = .Center
        
        self.tableView.backgroundColor     = UIColor.clearColor()
        self.tableView.layer.masksToBounds = true
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier:OptionSheetCellIdentifier)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInset.top = 45
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
        self.tableView.contentOffset.y = -self.tableView.contentInset.top
        
        self.closeButton.addTarget(self, action: #selector(OptionSheet.handleCloseButtonOnTap(_:)), forControlEvents: .TouchUpInside)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let contentHeight = self.tableView.frame.size.height - self.tableView.contentInset.top
        self.tableView.scrollEnabled = contentHeight < CGFloat(self.options.count) * self.cellHeight
    }
    
    
    // MARK: - Events
    func handleCloseButtonOnTap(sender: UIButton) {
        
        self.closeCallBack(sheet: self)
    }
    
    
    // MARK: - Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.options.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return self.cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(OptionSheetCellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = self.displayParser(sheet: self, option: self.options[indexPath.row])
        
        if cell.tag == 0 {
            
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
            cell.textLabel?.textColor = UIColor(white: 0.3, alpha: 1.0)
            
            cell.tag = Int.max
        }
        
        return cell
    }
    
    
    // MARK: - Table View Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedCallBack?(sheet: self, option: self.options[indexPath.row])
    }
}










