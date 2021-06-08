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
//  NodeHealthOperation.swift

import Foundation

class NodeHealthOperation: AsyncOperation {
    
    let address: String?
    let token: String?
    let api: AlgorandAPI
    
    var onStarted: EmptyHandler?
    var onCompleted: BoolHandler?
    
    init(node: Node, api: AlgorandAPI) {
        self.address = node.address
        self.token = node.token
        self.api = api
        super.init()
    }
    
    init(address: String?, token: String?, api: AlgorandAPI) {
        self.address = address
        self.token = token
        self.api = api
        super.init()
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let address = self.address,
            let token = self.token else {
                self.onCompleted?(false)
                self.state = .finished
            return
        }

        let nodeTestDraft = NodeTestDraft(address: address, token: token)
        api.checkNodeHealth(with: nodeTestDraft) { isHealthy in
            self.onCompleted?(isHealthy)
            self.state = .finished
        }
        
        onStarted?()
    }
}
