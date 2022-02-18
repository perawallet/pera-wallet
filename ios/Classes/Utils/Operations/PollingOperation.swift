// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  PollingOperation.swift

import UIKit

class PollingOperation {
    
    private var timer: DispatchSourceTimer?
    private let interval: TimeInterval
    private let handler: EmptyHandler
    
    private var isRunning = false
    
    // MARK: Initialization
    
    init(interval: TimeInterval, handler: @escaping EmptyHandler) {
        self.interval = interval
        self.handler = handler
    }
    
    deinit {
        invalidate()
    }
    
    // MARK: API
    
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        
        timer = DispatchSource.makeTimerSource()
        
        guard let timer = timer else {
            return
        }
        
        timer.schedule(deadline: .now() + interval, repeating: interval)
        
        timer.setEventHandler {
            self.handler()
        }
        
        timer.resume()
    }
    
    func invalidate() {
        guard let timer = timer else {
            
            isRunning = false
            
            return
        }
        
        timer.cancel()
        self.timer = nil
        
        isRunning = false
    }
}
