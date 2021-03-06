//
//  TimerManager.swift
//  YachtTimer
//
//  Created by Szamódy Zs. Balázs on 2017. 08. 28..
//  Copyright © 2017. Szamódy Zs. Balázs. All rights reserved.
//

import Foundation

protocol TimerManager: class {
    var counter: Int { get set }
    
    var counterReference: Int { get set }
    
    var timer: Timer? { get set }
    
    var endDate: Date? { get set }
    
    func startTimer()
    
    func stopTimer(_ timer: Timer)
    
    func syncResetTimer(_ timer: Timer?, resetCompletionHandler completion: (() -> Void)?)
    
    func counterFinished(_ timer: Timer)
    
    func addMinute(failure: (() -> Void)?, completion: (() -> Void)?)
    
    func subtractMinute(failure: (() -> Void)?, completion: (() -> Void)?)
    
    func manageSpeech(_ time: Int)
}

extension TimerManager {
    
    func startTimer() {
        if endDate == nil {
            endDate = Date().addingTimeInterval(TimeInterval(counter))
            counter -= 1
        }
        timer = Timer(timeInterval: 1, repeats: true) {_ in
            guard let endDate = self.endDate else { return }
            self.counter = Int(endDate.timeIntervalSince(Date()))
        }
        
        guard let timer = timer else { return }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func stopTimer(_ timer: Timer) {
        endDate = nil
        timer.invalidate()
        self.timer = nil
    }
    
    func syncResetTimer(_ timer: Timer?, resetCompletionHandler completion: (() -> Void)?) {
        if let timer = timer {
            stopTimer(timer)
            if counter % 60 > 30 {
                counter += 60 - ( counter % 60 )
            } else {
                counter -= counter % 60
            }
            guard counter != 0 else {
                counterFinished(timer)
                return
            }
            startTimer()
            
        } else {
            counter = counterReference
            if let completion = completion {
               completion()
            }
            
        }
        
    }
    
    func addMinute(failure: (() -> Void)?, completion: (() -> Void)?) {
        guard timer == nil else { return }
        guard counter < 3600 else {
            if let failure = failure {
                failure()
            }
            return
        }
        
        if let completion = completion {
            completion()
        }
        
        if counter % 60 != 0 {
            counter += 60 - ( counter % 60 )
        } else {
            counter += 60
        }
    }
    
    func subtractMinute(failure: (() -> Void)?, completion: (() -> Void)?) {
        guard timer == nil else { return }
        guard counter > 60 else {
            if let failure = failure {
            failure()
            }
        return
        }
        
        if let completion = completion {
            completion()
        }
        
        if counter % 60 != 0 {
            counter -=  counter % 60
        } else {
            counter -= 60
        }
    }
}
