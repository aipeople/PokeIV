//
//  PokemonCell.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography
import SDWebImage


class PokemonCell: UITableViewCell {
    
    // MARK: - Properties
    // UI
    let container     = UIView()
    let separator     = UIView()
    let pokemonView   = UIImageView()
    let move1Arrow    = UIImageView()
    let move2Arrow    = UIImageView()
    let nameLabel     = UILabel()
    let detailLabel   = UILabel()
    let cpLabel       = UILabel()
    let move1Label    = UILabel()
    let move2Label    = UILabel()
    let staLabel      = UILabel()
    let staValueLabel = UILabel()
    let defLabel      = UILabel()
    let defValueLabel = UILabel()
    let atkLabel      = UILabel()
    let atkValueLabel = UILabel()
    let ivLabel       = UILabel()
    let ivValueLabel  = UILabel()
    
    // Data 
    var pokemon : Pokemon? {
        didSet {
            self.pokemonChanged()
        }
    }
    
    
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
        
        self.container.addSubview(self.pokemonView)
        constrain(self.pokemonView) { (view) in
            view.left == view.superview!.left + 10
            view.top  == view.superview!.top + 10
            view.width == 100
            view.height == 100
        }
        
        self.container.addSubview(self.nameLabel)
        constrain(self.pokemonView, self.nameLabel) { (poke, view) in
            view.left    == poke.right + 10
            view.centerY == poke.centerY - 32
        }
        
        self.container.addSubview(self.cpLabel)
        constrain(self.nameLabel, self.cpLabel) { (name, view) in
            view.right   == view.superview!.right - 15
            view.left    == name.right + 10
            view.centerY == name.centerY
        }
        
        self.container.addSubview(self.detailLabel)
        constrain(self.pokemonView, self.detailLabel) { (poke, view) in
            view.left    == poke.right + 10
            view.centerY == poke.centerY - 13
        }
        
        self.container.addSubview(self.move1Arrow)
        constrain(self.pokemonView, self.move1Arrow) { (poke, view) in
            view.left    == poke.right + 10
            view.centerY == poke.centerY + 13
        }
        
        self.container.addSubview(self.move2Arrow)
        constrain(self.pokemonView, self.move2Arrow) { (poke, view) in
            view.left    == poke.right + 10
            view.centerY == poke.centerY + 34
        }
        
        self.container.addSubview(self.move1Label)
        constrain(self.pokemonView, self.move1Label) { (poke, view) in
            view.left    == poke.right + 24
            view.centerY == poke.centerY + 13
            view.width   <= view.superview!.width - 144 ~ 750
            view.width   >= 0
        }
        
        self.container.addSubview(self.move2Label)
        constrain(self.pokemonView, self.move2Label) { (poke, view) in
            view.left    == poke.right + 24
            view.centerY == poke.centerY + 34
            view.width   <= view.superview!.width - 144 ~ 750
            view.width   >= 0
        }
        
        self.container.addSubview(self.separator)
        constrain(self.separator) { (view) in
            view.left   == view.superview!.left + 10
            view.right  == view.superview!.right - 10
            view.bottom == view.superview!.bottom - 71
            view.height == 1
        }
        
        let layoutValue = {(name: UILabel, value: UILabel, posX: CGFloat) in
        
            self.container.addSubview(name)
            constrain(name) { (view) in
                view.left   == view.superview!.left + posX
                view.bottom == view.superview!.bottom - 10
                view.width  == 50
            }
            
            self.container.addSubview(value)
            constrain(value) { (view) in
                view.left   == view.superview!.left + posX
                view.bottom == view.superview!.bottom - 28
                view.width  == 50
            }
        }
        
        layoutValue(self.staLabel, self.staValueLabel, 5 + 0)
        layoutValue(self.defLabel, self.defValueLabel, 5 + 50)
        layoutValue(self.atkLabel, self.atkValueLabel, 5 + 100)
        
        self.container.addSubview(self.ivLabel)
        constrain(self.ivLabel) { (view) in
            view.right  == view.superview!.right  - 15
            view.bottom == view.superview!.bottom - 10
        }
        
        self.container.addSubview(self.ivValueLabel)
        constrain(self.ivValueLabel) { (view) in
            view.right  == view.superview!.right  - 15
            view.bottom == view.superview!.bottom - 26
        }
        
        
        // Setup views
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle  = .None
        
        self.container.backgroundColor = App.Color.Background.Level2
        self.container.layer.cornerRadius = 2
        
        self.pokemonView.image = UIImage(named: "image_unknown_pokemon")
        self.pokemonView.tintColor = App.Color.Text.Disable
        
        self.nameLabel.text = NSLocalizedString("Unknown", comment: "name placeholder")
        self.nameLabel.textColor = App.Color.Text.Hard
        self.nameLabel.font = UIFont.systemFontOfSize(18, weight: UIFontWeightSemibold)
        self.nameLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        
        self.cpLabel.text = "CP ???"
        self.cpLabel.textColor = App.Color.Main
        self.cpLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        self.cpLabel.textAlignment = .Right
        self.cpLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        
        self.detailLabel.text = "?? Kg / ?? M"
        self.detailLabel.textColor = App.Color.Text.Light
        self.detailLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightMedium)
        
        self.move1Arrow.image = UIImage(named: "image_move_arrow")
        self.move1Arrow.tintColor = App.Color.Text.Light
        
        self.move2Arrow.image = UIImage(named: "image_move_arrow")
        self.move2Arrow.tintColor = App.Color.Text.Light
        
        self.move1Label.text = "N/A"
        self.move1Label.textColor = App.Color.Text.Disable
        self.move1Label.font = UIFont.systemFontOfSize(16)
        
        self.move2Label.text = "N/A"
        self.move2Label.textColor = App.Color.Text.Disable
        self.move2Label.font = UIFont.systemFontOfSize(16)
        
        self.separator.backgroundColor = UIColor(white: 0, alpha: 0.15)
        
        self.staLabel.text = NSLocalizedString("STA", comment: "pokemon value")
        self.defLabel.text = NSLocalizedString("DEF", comment: "pokemon value")
        self.atkLabel.text = NSLocalizedString("ATK", comment: "pokemon value")
        
        for label in [self.staLabel, self.defLabel, self.atkLabel] {
            
            label.textColor = App.Color.Text.SemiLight
            label.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
            label.textAlignment = .Center
        }
        
        for label in [self.staValueLabel, self.defValueLabel, self.atkValueLabel] {
            
            label.text = "?"
            label.textColor = App.Color.Text.Hard
            label.font = UIFont.systemFontOfSize(28, weight: UIFontWeightLight)
            label.textAlignment = .Center
        }
        
        self.ivLabel.text = NSLocalizedString("IVs Score", comment: "pokemon value")
        self.ivLabel.textColor = App.Color.Main.colorWithAlphaComponent(0.75)
        self.ivLabel.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        self.ivLabel.textAlignment = .Right
        
        self.ivValueLabel.text = "?? %"
        self.ivValueLabel.textColor = App.Color.Main
        self.ivValueLabel.font = UIFont.systemFontOfSize(32)
        self.ivValueLabel.textAlignment = .Right
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Events 
    func pokemonChanged() {
        
        if let pokemon = self.pokemon {
            
            // Image
            if let path = NSBundle.mainBundle().pathForResource("pokemonImages/pokemon_\(pokemon.pokemonId.rawValue)", ofType: "png") {
                let url = NSURL(fileURLWithPath: path)
                self.pokemonView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "image_unknown_pokemon"))
            } else {
                self.pokemonView.image = UIImage(named: "image_unknown_pokemon")
            }
            
            // Name
            if pokemon.hasNickname {
                self.nameLabel.text = pokemon.nickname
            } else if pokemon.hasId {
                self.nameLabel.text = pokemon.pokemonId.toString().stringByReplacingOccurrencesOfString("_", withString: " ")
            } else {
                self.nameLabel.text = NSLocalizedString("Unknown", comment: "name placeholder")
            }
            
            // Detail
            var detailText = ""
            if pokemon.hasWeightKg {
                detailText += String(format: "%.1f Kg / ", pokemon.weightKg)
            } else {
                detailText += "?? Kg / "
            }
            if pokemon.hasHeightM {
                detailText += String(format: "%.1f M", pokemon.heightM)
            } else {
                detailText += "?? M"
            }
            self.detailLabel.text = detailText
            
            // CP
            self.cpLabel.text = "CP " + (pokemon.hasCp ? String(pokemon.cp) : "???")
            
            // Move1
            if pokemon.hasMove1 {
                self.move1Label.text = pokemon.move1.toString().stringByReplacingOccurrencesOfString("_", withString: " ")
                self.move1Label.textColor = App.Color.Text.Normal
            } else {
                self.move1Label.text = "N/A"
                self.move1Label.textColor = App.Color.Text.Disable
            }
            
            // Move2
            if pokemon.hasMove2 {
                self.move2Label.text = pokemon.move2.toString().stringByReplacingOccurrencesOfString("_", withString: " ")
                self.move2Label.textColor = App.Color.Text.Normal
            } else {
                self.move2Label.text = "N/A"
                self.move2Label.textColor = App.Color.Text.Disable
            }
            
            // Values
            let sta = pokemon.hasIndividualStamina ? pokemon.individualStamina : 0
            let def = pokemon.hasIndividualDefense ? pokemon.individualDefense : 0
            let atk = pokemon.hasIndividualAttack  ? pokemon.individualAttack  : 0
            self.staValueLabel.text = String(sta)
            self.defValueLabel.text = String(def)
            self.atkValueLabel.text = String(atk)
            
            let iv = Double(pokemon.individualStamina + pokemon.individualDefense + pokemon.individualAttack) / 45.0
            self.ivValueLabel.text = String(format: "%.1f %%", iv * 100)
            
        } else {
            
            self.pokemonView.image = UIImage(named: "image_unknown_pokemon")
            self.nameLabel.text = NSLocalizedString("Unknown", comment: "name placeholder")
            self.cpLabel.text = "CP ???"
            self.ivValueLabel.text = "?? %"
            self.detailLabel.text = "?? Kg / ?? M"
            self.move1Label.text = "N/A"
            self.move1Label.textColor = App.Color.Text.Disable
            self.move2Label.text = "N/A"
            self.move2Label.textColor = App.Color.Text.Disable
            
            for label in [self.staValueLabel, self.defValueLabel, self.atkValueLabel] {
                label.text = "?"
            }
        }
    }
}











