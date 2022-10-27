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
//   ALGBlockCycle.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class ALGBlockCycle: BlockCycle {
    private var notificationQueue: DispatchQueue?
    private var notificationHandler: NotificationHandler?

    private var ongoingEndpointToWaitForNextBlock: EndpointOperatable?

    private let api: ALGAPI

    init(
        api: ALGAPI
    ) {
        self.api = api
    }
}

extension ALGBlockCycle {
    func notify(
        queue: DispatchQueue,
        execute handler: @escaping NotificationHandler
    ) {
        notificationQueue = queue
        notificationHandler = handler
    }
    
    func startListening() {
        sendNotification()
        watchNextBlock(notifyForUpdate: false)
    }

    func stopListening() {
        ongoingEndpointToWaitForNextBlock?.cancel()
        ongoingEndpointToWaitForNextBlock = nil
    }
    
    func cancelListening() {
        stopListening()
    }
}

extension ALGBlockCycle {
    private func watchNextBlock(
        notifyForUpdate: Bool
    ) {
        watchNextBlock(
            after: 0,
            notifyForUpdate: notifyForUpdate
        )
    }
    
    private func watchNextBlock(
        after round: BlockRound,
        notifyForUpdate: Bool
    ) {
        waitForNextBlock(after: round) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let roundDetail):
                if notifyForUpdate {
                    self.sendNotification()
                }

                self.watchNextBlock(
                    after: roundDetail.lastRound,
                    notifyForUpdate: true
                )
            case .failure:
                /// <todo>
                /// How to handle network/server errors?
                self.watchNextBlock(notifyForUpdate: true)
            }
        }
    }
}

extension ALGBlockCycle {
    private typealias WaitForNextBlockCompletionHandler = (Result<RoundDetail, HIPNetworkError<NoAPIModel>>) -> Void
    
    private func waitForNextBlock(
        after round: BlockRound,
        onCompletion handler: @escaping WaitForNextBlockCompletionHandler
    ) {
        let draft = WaitRoundDraft(round: round)
        
        ongoingEndpointToWaitForNextBlock?.cancel()
        ongoingEndpointToWaitForNextBlock =
            api.waitRound(draft) { [weak self] result in
                guard let self = self else { return }
                
                self.ongoingEndpointToWaitForNextBlock = nil
                
                switch result {
                case .success(let roundDetail):
                    handler(.success(roundDetail))
                case .failure(let apiError, let apiErrorDetail):
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler(.failure(error))
                }
            }
    }
}

extension ALGBlockCycle {
    private func sendNotification() {
        notificationQueue?.async { [weak self] in
            guard let self = self else { return }
            self.notificationHandler?()
        }
    }
}

typealias BlockRound = UInt64
