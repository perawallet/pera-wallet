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
//   ALGBlockOperationQueue.swift


import Foundation
import MacaroonUtils

final class ALGBlockOperationQueue {
    var isAvailable: Bool {
        return underlyingOperationsGroupedByAccountAddress.isEmpty
    }
    
    private lazy var underlyingQueue = createUnderlyingQueue()

    @Atomic(identifier: "blockOperationQueue.underlyingOperations")
    private var underlyingOperationsGroupedByAccountAddress: [String: [Operation]] = [:]
}

extension ALGBlockOperationQueue {
    func enqueue(
        _ operation: Operation
    ) {
        underlyingQueue.addOperation(operation)
    }
    
    func enqueue(
        _ operations: [Operation],
        forAccountAddress address: String
    ) {
        $underlyingOperationsGroupedByAccountAddress.mutate { $0[address] = operations }
        underlyingQueue.addOperations(
            operations,
            waitUntilFinished: false
        )
    }
    
    func dequeueOperations(
        forAccountAddress address: String
    ) {
        $underlyingOperationsGroupedByAccountAddress.mutate { $0[address] = nil }
    }
}

extension ALGBlockOperationQueue {
    func addBarrier(
        _ barrier: @escaping () -> Void
    ) {
        underlyingQueue.addBarrierBlock(barrier)
    }
}

extension ALGBlockOperationQueue {
    func cancelAllOperations() {
        $underlyingOperationsGroupedByAccountAddress.mutate { $0 = [:] }
        underlyingQueue.cancelAllOperations()
    }
}

extension ALGBlockOperationQueue {
    private func createUnderlyingQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.name = "com.algorand.blockOperationQueue"
        queue.qualityOfService = .userInitiated
        return queue
    }
}
