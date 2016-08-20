//
//  NSErrorExtension.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import Foundation


extension NSError {
    
    convenience init(code: Int, description: String) {
        self.init(domain: "su.pokeIV.com", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    convenience init(domain: String, code: Int, description: String) {
        self.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}


typealias ErrorCode = Int

extension ErrorCode {
    
    func nserror() -> NSError {
        return Error.errorWithCode(self)
    }
}

struct Error {
    
    static let Domain = "su.pokeIV.com"
    
    struct Code {
        
        static let Common = 0
        
        static let Login         = 1000
        static let Authorization = 1001
        static let Connection    = 1002
        static let ResoveData    = 1003
    }
    
    static func errorWithCode(code: Int) -> NSError {
        
        return NSError(code: code, description: Error.messageWithCode(code))
    }
    
    static func messageWithCode(code: Int) -> String {
        
        var message = ""
        
        switch code {
            
        case Error.Code.Login:
            message = NSLocalizedString(
                "Login failed. Please make sure you have entered the correct account/password. Currently not support Google two factor authentication.",
                comment: "Login failed")
            
        case Error.Code.Authorization:
            message = NSLocalizedString(
                "Authorization failed. Please login again.",
                comment: "Authorization failed")
            
        case Error.Code.Connection:
            message = NSLocalizedString(
                "Connection failed. Please try again later.",
                comment: "Connection failed")
            
        case Error.Code.ResoveData:
            message = NSLocalizedString(
                "Failed to resolve data. Please try again later.",
                comment: "Failed to resolve data")
            
        default:
            message = NSLocalizedString(
                "Unknown error. Please login again to solve this problem.",
                comment: "Common error")
        }
        
        return message// + " (\(code))"
    }
}