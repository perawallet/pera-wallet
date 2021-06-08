// Copyright 2019 Algorand, Inc.

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
//  NodeController.swift

import Foundation

class NodeController {
    let api: AlgorandAPI
    let queue: OperationQueue
    
    init(api: AlgorandAPI) {
        self.api = api
        self.queue = OperationQueue()
        self.queue.name = "NodeFetchOperation"
        self.queue.maxConcurrentOperationCount = 1
    }
}

extension NodeController {
    func checkNodeHealth(completion: BoolHandler?) {
        let completionOperation = BlockOperation {
            completion?(false)
        }
        
        let localNodeOperation = self.localNodeOperation(completion: completion)
        completionOperation.addDependency(localNodeOperation)
        queue.addOperation(localNodeOperation)
        queue.addOperation(completionOperation)
    }
    
    private func localNodeOperation(completion: BoolHandler?) -> NodeHealthOperation {
        let address = Environment.current.serverApi
        let token = Environment.current.algodToken
        let localNodeHealthOperation = NodeHealthOperation(address: address, token: token, api: api)
        
        localNodeHealthOperation.onCompleted = { isHealthy in
            if isHealthy {
                self.setNewNode(with: address, and: token, then: completion)
            }
        }
        
        return localNodeHealthOperation
    }
    
    private func setNewNode(with address: String, and token: String, then completion: BoolHandler?) {
         api.cancelEndpoints()
         api.base = address
         api.algodToken = token
         completion?(true)
         queue.cancelAllOperations()
     }
}
