//
//  PokemonsVIewController.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import Cartography
import SDWebImage
import FBAudienceNetwork
import Firebase


extension PokemonsViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return .LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        return false
    }

    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        
        return .Slide
    }
}


class PokemonsViewController : UIViewController {
    
    // MARK: - Properties
    // Class
    static let SortOptionKey = "sort"
    static let LoadingCellIdentifier = "loading"
    static let InfoCellIdentifier = "cell"
    static let AdCellIdentifier = "ad"
    
    // UI
    let topBar       = UIView()
    let titleLabel   = UILabel()
    let logoutButton = UIButton(type: .System)
    let sortButton   = UIButton(type: .System)
    let tableView    = UITableView()
    let refreshControl = UIRefreshControl()
    
    // Data
    let adInterval = 0
    var adUpdateTime = 0.0
    var adUpdateInterval = 60.0
    var adTimer  : NSTimer!
    var nativeAd : FBNativeAd?
    
    var isActive = true
    
    var pokemons : [Pokemon]?
    var displayPokemons : [Pokemon]?
    
    
    // MARK: - Life Cycle
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        
        // Setup constraints
        self.view.addSubview(self.tableView)
        constrain(self.tableView) { (view) in
            view.edges == view.superview!.edges
        }
        
        self.view.addSubview(self.topBar)
        constrain(self.topBar) { (view) in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.height == 64
        }
        
        self.topBar.addSubview(self.titleLabel)
        constrain(self.titleLabel) { (view) in
            view.centerX == view.superview!.centerX
            view.centerY == view.superview!.centerY + 10
        }
        
        self.topBar.addSubview(self.logoutButton)
        constrain(self.logoutButton) { (view) in
            view.left    == view.superview!.left + 5
            view.centerY == view.superview!.centerY + 10
            view.width   == 44
            view.height  == 44
        }
        
        self.topBar.addSubview(self.sortButton)
        constrain(self.sortButton) { (view) in
            view.right   == view.superview!.right - 5
            view.centerY == view.superview!.centerY + 10
            view.width   == 44
            view.height  == 44
        }
        
        self.tableView.addSubview(self.refreshControl)
        
        
        // Setup Views
        self.view.backgroundColor = App.Color.Background.Level1
        self.topBar.backgroundColor = App.Color.Background.Level1
        self.tableView.backgroundColor = UIColor.clearColor()
        
        self.titleLabel.text = "PokeIV"
        self.titleLabel.textColor = App.Color.Text.Hard
        self.titleLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
        
        self.logoutButton.setImage(UIImage(named: "icon_power"), forState: .Normal)
        self.logoutButton.tintColor = App.Color.Main
        self.logoutButton.addTarget(self, action: #selector(handleLogoutButtonOnTap(_:)), forControlEvents: .TouchUpInside)
        
        self.sortButton.setImage(UIImage(named: "icon_sort"), forState: .Normal)
        self.sortButton.tintColor = App.Color.Main
        self.sortButton.addTarget(self, action: #selector(handleSortButtonOnTap(_:)), forControlEvents: .TouchUpInside)
        
        self.tableView.separatorStyle = .None
        self.tableView.delaysContentTouches = false
        self.tableView.contentInset = UIEdgeInsets(top: 69, left: 0, bottom: 4, right: 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 69, left: 0, bottom: 4, right: 0)
        self.tableView.contentOffset.y = -69
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        self.tableView.registerClass(PokemonCell.self,
            forCellReuseIdentifier: PokemonsViewController.InfoCellIdentifier
        )
        self.tableView.registerClass(LoadingCell.self,
            forCellReuseIdentifier: PokemonsViewController.LoadingCellIdentifier
        )
        self.tableView.registerClass(AdCell.self,
            forCellReuseIdentifier: PokemonsViewController.AdCellIdentifier
        )
        
        self.refreshControl.addTarget(self,
            action: #selector(handleRefreshControlChanged(_:)),
            forControlEvents: .ValueChanged
        )
        
        for view in self.tableView.subviews {
            if let view = view as? UIScrollView {
                view.delaysContentTouches = false
            }
        }
        
        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(handleAppWillResignActive(_:)),
            name: UIApplicationWillResignActiveNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(handleAppDidBecomeActive(_:)),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
        
        // Setup Ad
        if self.adInterval > 0 {
            
            self.adTimer = NSTimer.scheduledTimerWithTimeInterval(5,
                target: self,
                selector: #selector(handleAdRefreshUpdate(_:)),
                userInfo: nil,
                repeats: true
            )
            self.loadNativeAd()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !self.view.hidden {
            self.tableView.reloadData()
            self.refreshControl.beginRefreshing()
            self.fetchData()
        }
    }
    
    
    // MARK: - Methods
    func fetchData() {
        
        PokeManager.defaultManager.fetchPokemons { (pokemons, error) in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { 
                
                if let error = error  {
                    
                    Control.onMain({ 
                        
                        if error.code == Error.Code.Authorization {
                            
                            let title = NSLocalizedString("Authorization Expired", comment: "message title")
                            PopoverView.popMessageWithTitle(title, message: error.localizedDescription) { contentView, _ in
                                
                                self.handleLogoutButtonOnTap(self.logoutButton)
                                contentView.popoverView?.dismiss()
                            }
                            
                        } else {
                            let title = NSLocalizedString("Error", comment: "message title")
                            PopoverView.popMessageWithTitle(title, message: error.localizedDescription)
                        }
                    })
                    
                } else {
                    let existPokemons = pokemons?.filter({!$0.isEgg})
                    self.pokemons = existPokemons
                }
                self.sortPokemons()
                
                Control.onMain({
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func sortPokemons() {
        
        if let pokemons = self.pokemons {
        
            var option = PokemonSort.CapturedDate
            if  let sortOptionValue = NSUserDefaults.standardUserDefaults().stringForKey(PokemonsViewController.SortOptionKey),
                let sortOption = PokemonSort(rawValue: sortOptionValue){
                option = sortOption
            } else {
                NSUserDefaults.standardUserDefaults()
                    .setObject(option.rawValue, forKey: PokemonsViewController.SortOptionKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            
            let decending = NSUserDefaults.standardUserDefaults().boolForKey(SortOptionSheet.DecendingEnabledKey)
            
            switch(option) {
                
            case .PokemonID:
                
                self.displayPokemons = pokemons.sort({
                    
                    if $0.0.pokemonId.rawValue == $0.1.pokemonId.rawValue {
                        return $0.0.creationTimeMs <= $0.1.creationTimeMs
                    } else {
                        return decending ?
                            $0.0.pokemonId.rawValue >= $0.1.pokemonId.rawValue :
                            $0.0.pokemonId.rawValue <= $0.1.pokemonId.rawValue
                    }
                })
                break
                
            case .CombatPower:
                
                self.displayPokemons = pokemons.sort({
                    
                    if $0.0.cp == $0.1.cp {
                        return $0.0.creationTimeMs <= $0.1.creationTimeMs
                    } else {
                        return decending ?
                            $0.0.cp >= $0.1.cp :
                            $0.0.cp <= $0.1.cp
                    }
                })
                break
                
            case .IndividualValue:
                
                self.displayPokemons = pokemons.sort({
                    
                    let l_iv = $0.0.individualStamina + $0.0.individualDefense + $0.0.individualAttack
                    let r_iv = $0.1.individualStamina + $0.1.individualDefense + $0.1.individualAttack
                    
                    if l_iv == r_iv {
                        return $0.0.pokemonId.rawValue <= $0.1.pokemonId.rawValue
                    } else {
                        return decending ?
                            l_iv >= r_iv :
                            l_iv <= r_iv
                    }
                })
                break
            
            default:
                
                self.displayPokemons = pokemons.sort({
                    decending ?
                        $0.0.creationTimeMs >= $0.1.creationTimeMs :
                        $0.0.creationTimeMs <= $0.1.creationTimeMs
                })
            }
        } else {
            
            self.displayPokemons = nil
        }
    }
    
    func loadNativeAd() {
        
        /*
         * let nativeAd = FBNativeAd(placementID: <Placement ID>)
         * nativeAd.delegate = self
         * nativeAd.loadAd()
         */
    }
    
    
    // MARK: - Events
    func handleRefreshControlChanged(sender: UIRefreshControl) {
        
        if sender.refreshing {
            
            self.fetchData()
        }
    }
    
    func handleSortButtonOnTap(sender: UIButton) {
        
        let sheet = SortOptionSheet()
        sheet.selectedCallBack = { (sheet, option) in
            
            // Save selections
            NSUserDefaults.standardUserDefaults()
                .setObject(option.rawValue, forKey: PokemonsViewController.SortOptionKey)
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
            // Log
            let desc = (sheet as? SortOptionSheet)?.sortingSwitch.on ?? false
            FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
                kFIRParameterContentType: "sort",
                kFIRParameterItemID: option.rawValue + " - " + (desc ? "desc" : "asc")
            ])
            
            // Sort
            sheet.popoverView?.dismiss()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                self.sortPokemons()
                Control.onMain({ 
                    self.tableView.reloadData()
                })
            })
        }
        
        sheet.sortingChangedCallback = { (sheet) in
            
            NSUserDefaults.standardUserDefaults()
                .setBool(sheet.sortingSwitch.on, forKey: SortOptionSheet.DecendingEnabledKey)
            
            // Sort
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                self.sortPokemons()
                Control.onMain({
                    self.tableView.reloadData()
                })
            })
        }
        
        let popoverView = PopoverView(contentView: sheet)
        popoverView.presentWithDuration(0.4,
            setupConstraint: Popover.inCenter(300, height: 400)
        )
    }
    
    func handleLogoutButtonOnTap(sender: UIButton) {
        
        PokeManager.defaultManager.logout()
        self.pokemons = nil
        self.displayPokemons = nil
        
        UIApplication.rootViewController.switchToLoginState(true)
    }
    
    func handleAdRefreshUpdate(sender: NSTimer) {
        
        let time = NSDate().timeIntervalSince1970
        let duration = time - self.adUpdateTime
        
        if !self.view.hidden &&
            self.isActive &&
            duration >= self.adUpdateInterval {
            self.adUpdateTime = time
            self.loadNativeAd()
        }
    }
    
    func handleAppWillResignActive(sender: NSNotification) {
        
        self.isActive = false
        self.refreshControl.endRefreshing()
    }
    
    func handleAppDidBecomeActive(sender: NSNotification) {
        
        self.isActive = true
    }
}


extension PokemonsViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.adInterval == 0 {
            return self.displayPokemons?.count ?? 3
        } else {
            let num = self.displayPokemons?.count ?? 2
            return num + max(1, Int(floor(Double(num) / Double(self.adInterval))))
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.displayPokemons != nil {
            
            let shouldDisplayAd = self.shouldDisplayAdAtIndexPath(indexPath)
            if  shouldDisplayAd {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(
                    PokemonsViewController.AdCellIdentifier,
                    forIndexPath: indexPath
                )
                if  let cell = cell as? AdCell {
                    cell.nativeAd = self.nativeAd
                }
                
                return cell
                
            } else {
                
                let dataIndex = indexPath.row - (self.adInterval == 0 ? 0 : Int(floor(Double(indexPath.row) / Double(self.adInterval + 1))))
                let cell = tableView.dequeueReusableCellWithIdentifier(
                    PokemonsViewController.InfoCellIdentifier,
                    forIndexPath: indexPath
                )
                
                if  let cell = cell as? PokemonCell
                    where dataIndex < self.displayPokemons?.count {
                    
                    if let pokemon = self.displayPokemons?[dataIndex] {
                        cell.pokemon = pokemon
                    }
                }
                
                return cell
            }
            
        } else {
            
            return tableView.dequeueReusableCellWithIdentifier(
                PokemonsViewController.LoadingCellIdentifier,
                forIndexPath: indexPath
            )
        }
    }
    
    func shouldDisplayAdAtIndexPath(indexPath: NSIndexPath) -> Bool {
        
        guard self.adInterval > 0 else {return false}
        guard self.displayPokemons != nil else {return false}
        
        let dataIndex = indexPath.row - Int(floor(Double(indexPath.row) / Double(self.adInterval + 1)))
        var shouldDisplayAd = false
        
        if indexPath.row > 0 && indexPath.row % (self.adInterval + 1) == 0 {
            shouldDisplayAd = true
        } else if dataIndex >= self.displayPokemons?.count{
            shouldDisplayAd = true
        }
        return shouldDisplayAd
    }
}


extension PokemonsViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let shouldDisplayAd = self.shouldDisplayAdAtIndexPath(indexPath)
        
        return shouldDisplayAd ? 240 : 200
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.bringSubviewToFront(cell)
    }
}


extension PokemonsViewController : FBNativeAdDelegate {
    
    func nativeAdDidLoad(nativeAd: FBNativeAd) {
        
        self.nativeAd = nativeAd
        
        for cell in self.tableView.visibleCells {
            if let cell = cell as? AdCell {
                cell.nativeAd = nativeAd
            }
        }
    }
}









