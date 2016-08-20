//
//  PokeManager.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import UIKit
import PGoApi
import ProtocolBuffers
import RNCryptor


enum AuthType : Int {
    
    case PokeClub
    case Google
}

typealias Pokemon = Pogoprotos.Data.PokemonData

class PokeManager {
    
    // MARK: - Properties
    static let UsernameKey = "u"
    static let PasswordKey = "p"
    static let AuthTypeKey = "a"
    static let defaultManager = PokeManager()
    
    var auth: PGoAuth?
    var updatedTime = 0
    var logined = false
    
    typealias ReadyHandler = ()->()
    var readyHandler : ReadyHandler?
    
    typealias LoginHandler = (NSError?)->()
    var loginHandler : LoginHandler?
    
    typealias FetchHandler = ([Pokemon]?, NSError?)->()
    var fetchHandler : FetchHandler?
    
    private var username : String?
    private var password : String?
    private var authType : AuthType?
    
    
    // MARK: - Life Cycle
    init() {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if  let _ = userDefault.stringForKey(PokeManager.UsernameKey),
            let _ = userDefault.dataForKey(PokeManager.PasswordKey) {
            self.logined = true
        }
    }
    
    
    // MARK: - Auth
    func loginWithUserName(username: String, password: String, handler: LoginHandler?) {
        
        self.loginHandler = handler
        self.username = username
        self.password = password
        self.authType = .PokeClub
        
        self.auth = PtcOAuth()
        self.auth?.delegate = self
        self.auth?.login(withUsername: username, withPassword: password)
    }
    
    func loginWithGmail(email: String, password: String, handler: LoginHandler?) {
        
        let username = email.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        self.loginHandler = handler
        self.username = username
        self.password = password
        self.authType = .Google
        
        self.auth = GPSOAuth()
        self.auth?.delegate = self
        self.auth?.login(withUsername: username, withPassword: password)
    }
    
    func autoAuth(handler: LoginHandler?) {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if  let username = userDefault.stringForKey(PokeManager.UsernameKey),
            let encryptData = userDefault.dataForKey(PokeManager.PasswordKey),
            let passwordData = try? RNCryptor.decryptData(encryptData, password: username + "pokeIV"),
            let password = String(data: passwordData, encoding: NSUTF8StringEncoding) {
            let authType = userDefault.integerForKey(PokeManager.AuthTypeKey)
            
            if AuthType(rawValue: authType) == .PokeClub {
                self.loginWithUserName(username, password: password, handler: handler)
            } else {
                self.loginWithGmail(username, password: password, handler: handler)
            }
        }
    }
    
    func logout() {
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey(PokeManager.UsernameKey)
        userDefault.removeObjectForKey(PokeManager.PasswordKey)
        userDefault.removeObjectForKey(PokeManager.AuthTypeKey)
        
        self.logined = false
        self.auth = nil
    }
    
    func saveLoginInfo() {
        
        if  let username = self.username,
            let password = self.password,
            let authType = self.authType,
            let data = password.dataUsingEncoding(NSUTF8StringEncoding) {
            
            let key = username + "pokeIV"
            let encryptData = RNCryptor.encryptData(data, password: key)
        
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setObject(username,   forKey: PokeManager.UsernameKey)
            userDefault.setObject(encryptData, forKey: PokeManager.PasswordKey)
            userDefault.setInteger(authType.rawValue, forKey: PokeManager.AuthTypeKey)
            userDefault.synchronize()
        }
    }
    
    
    // MARK: - Fetch
    func fetchPokemons(handler: FetchHandler?) {
        
        let fetch = {
            
            if let auth = self.auth {
                
                self.fetchHandler = handler
                
                let request = PGoApiRequest(auth: auth)
                request.getInventory()
                request.makeRequest(.GetInventory, delegate: self)
            }
        }
        
        if let _ = self.auth {
            
            fetch()
            
        } else if self.logined {
            
            self.autoAuth() { (error) in
                
                if error != nil {
                    
                    handler?(nil, Error.Code.Authorization.nserror())
                    
                } else {
                    fetch()
                }
            }
        } else {
            
            handler?(nil, Error.Code.Authorization.nserror())
        }
    }
}


extension PokeManager : PGoAuthDelegate {
    
    func didReceiveAuth() {
        
        if let auth = self.auth {
            let request = PGoApiRequest(auth: auth)
            request.getInventory()
            request.makeRequest(.Login, delegate: self)
        }
    }
    
    func didNotReceiveAuth() {
        
        self.loginHandler?(Error.Code.Login.nserror())
        self.loginHandler = nil
    }
}


extension PokeManager : PGoApiDelegate {
    
    func didReceiveApiResponse(intent: PGoApiIntent, response: PGoApiResponse) {
    
        if (intent == .Login) {
            
            if let envelope = response.response as? Pogoprotos.Networking.Envelopes.ResponseEnvelope {
                
                self.auth?.endpoint = "https://" + envelope.apiUrl + "/rpc"
                
                self.saveLoginInfo()
                self.loginHandler?(nil)
                self.loginHandler = nil
            
            } else {
            
                self.loginHandler?(Error.Code.Authorization.nserror())
                self.loginHandler = nil
            }
        }
        
        if (intent == .GetInventory) {
        
            let response = response.subresponses.first as? Pogoprotos.Networking.Responses.GetInventoryResponse
            
            if let inventories = response?.inventoryDelta.inventoryItems {
            
                var pokemons = Array<Pogoprotos.Data.PokemonData>()
                for inventory in inventories {
                    if inventory.inventoryItemData.hasPokemonData {
                        pokemons.append(inventory.inventoryItemData.pokemonData)
                    }
                }
                self.fetchHandler?(pokemons, nil)
                self.fetchHandler = nil
                
            } else {
                
                self.autoAuth({ (error) in
                    
                    self.fetchHandler?(nil, Error.Code.ResoveData.nserror())
                    self.fetchHandler = nil
                })
            }
        }
    }
    
    func didReceiveApiError(intent: PGoApiIntent, statusCode: Int?) {
        
        if intent == .Login {
            
            self.loginHandler?(Error.Code.Connection.nserror())
            self.loginHandler = nil
            
        } else if intent == .GetInventory {
            
            if statusCode == nil {
                
                self.autoAuth({ (error) in
                    
                    self.fetchHandler?(nil, Error.Code.Connection.nserror())
                    self.fetchHandler = nil
                })
            } else {
                
                self.fetchHandler?(nil, Error.Code.Connection.nserror())
                self.fetchHandler = nil
            }
        }
    }
}









