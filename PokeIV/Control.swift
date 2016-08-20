//
//  Control.swift
//  PokeIV
//
//  Created by aipeople on 8/15/16.
//  Github: https://github.com/aipeople/PokeIV
//  Copyright © 2016 su. All rights reserved.
//

import Foundation

struct Control {
    
    typealias ControlPassCall = () -> ()
    
    static func wait(task: (pass: ControlPassCall) -> ()) {
        
        self.wait(1, task)
    }
    static func wait(taskNum: Int, _ task: (pass: ControlPassCall) -> ()) {
        
        let semaphore = dispatch_semaphore_create(0)
        let pass: ControlPassCall = {dispatch_semaphore_signal(semaphore)}
        task(pass: pass)
        
        for _ in 0 ..< taskNum {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
    }
    
    static func async(task:() -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            task()
        }
    }
    
    static func onMain(task:() -> ()) {
        
        dispatch_async(dispatch_get_main_queue()) {
            task()
        }
    }
    
    static func delay(delay: NSTimeInterval, _ task:() -> ()) {
        
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * NSTimeInterval(NSEC_PER_SEC))),
                dispatch_get_main_queue(), {
                    
                task()
            })
    }
}