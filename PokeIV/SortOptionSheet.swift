//
//  SortOptionSheet.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography


enum PokemonSort : String {
    
    case PokemonID   = "Pokemon ID"
    case CombatPower = "Combat Power"
    case IndividualValue = "Individual Value"
    case CapturedDate    = "Captured Date"
}

class SortOptionSheet: OptionSheet<PokemonSort> {
    
    // MARK: - Properties
    // Class
    static let DecendingEnabledKey = "decending"
    
    // UI
    let headContainer = UIView()
    let sortingLabel  = UILabel()
    let sortingSwitch = UISwitch()
    
    // Data
    var sortingChangedCallback : ((SortOptionSheet) -> ())?
    
    
    init() {
        
        super.init(options: [
            PokemonSort.PokemonID,
            PokemonSort.CombatPower,
            PokemonSort.IndividualValue,
            PokemonSort.CapturedDate
        ])
        
        self.headContainer.frame = CGRectMake(0, 0, 320, 44)
        self.tableView.tableHeaderView = self.headContainer
        
        self.headContainer.addSubview(self.sortingLabel)
        constrain(self.sortingLabel) { (view) in
            view.left == view.superview!.left + 15
            view.centerY == view.superview!.centerY
        }
        
        self.headContainer.addSubview(self.sortingSwitch)
        constrain(self.sortingSwitch) { (view) in
            view.right == view.superview!.right - 15
            view.centerY == view.superview!.centerY
        }
        
        // Setup Views
        self.title = NSLocalizedString("Sort By", comment: "sorting option sheet title")
        self.displayParser = { (sheet, option) in
            
            return option.rawValue
        }
        
        self.sortingLabel.text = NSLocalizedString("Sort in decending", comment: "sorting option")
        self.sortingLabel.textColor = App.Color.Text.Normal
        self.sortingLabel.font = UIFont.systemFontOfSize(16)
        
        self.headContainer.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        self.sortingSwitch.onTintColor = App.Color.Main
        
        self.sortingSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(SortOptionSheet.DecendingEnabledKey)
        self.sortingSwitch.addTarget(self,
            action: #selector(handleSwitchValueChanged(_:)),
            forControlEvents: .ValueChanged
        )
    }
    
    
    func handleSwitchValueChanged(sender: UISwitch) {
        
        self.sortingChangedCallback?(self)
    }
}









