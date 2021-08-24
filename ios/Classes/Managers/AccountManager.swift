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
//  AccountManager.swift

import Foundation

class AccountManager {
    let api: AlgorandAPI
    var currentRound: Int64?
    var params: TransactionParams?
    let queue: OperationQueue

    weak var delegate: AccountManagerDelegate?
    
    init(api: AlgorandAPI) {
        self.api = api
        self.queue = OperationQueue()
        self.queue.name = "AccountFetchOperation"
        self.queue.maxConcurrentOperationCount = 1
    }
}

extension AccountManager {
    func fetchAllAccounts(isVerifiedAssetsIncluded: Bool, completion: EmptyHandler?) {
        if isVerifiedAssetsIncluded {
            api.getVerifiedAssets { result in
                switch result {
                case let .success(list):
                    self.api.session.verifiedAssets = list.results
                    self.fetchAccounts(completion: completion)
                case .failure:
                    self.fetchAccounts(completion: completion)
                }
            }
        } else {
            fetchAccounts(completion: completion)
        }
    }
    
    private func fetchAccounts(completion: EmptyHandler?) {
        let completionOperation = BlockOperation {
            completion?()
        }
        
        guard let userAccounts = api.session.authenticatedUser?.accounts else {
            queue.addOperation(completionOperation)
            return
        }
        
        for account in userAccounts {
            let accountFetchOperation = AccountFetchOperation(accountInformation: account, api: api)
            accountFetchOperation.onCompleted = { fetchedAccount, _ in
                guard let fetchedAccount = fetchedAccount else {
                    return
                }
                
                fetchedAccount.name = account.name
                fetchedAccount.type = account.type
                fetchedAccount.ledgerDetail = account.ledgerDetail
                fetchedAccount.receivesNotification = account.receivesNotification
                fetchedAccount.rekeyDetail = account.rekeyDetail
                
                guard let currentAccount = self.api.session.account(from: fetchedAccount.address) else {
                    self.api.session.addAccount(fetchedAccount)
                    return
                }
                
                if fetchedAccount.amount == currentAccount.amount &&
                    fetchedAccount.rewards == currentAccount.rewards &&
                    !fetchedAccount.hasDifferentAssets(than: currentAccount) {
                    return
                }
                
                self.api.session.addAccount(fetchedAccount)
            }
            completionOperation.addDependency(accountFetchOperation)
            queue.addOperation(accountFetchOperation)
        }
        
        queue.addOperation(completionOperation)
    }
    
    func waitForNextRoundAndFetchAccounts(round: Int64?, completion: ((Int64?) -> Void)?) {
        if let nextRound = round {
            self.api.waitRound(with: WaitRoundDraft(round: nextRound)) { roundDetailResponse in
                switch roundDetailResponse {
                case let .success(result):
                    let round = result.lastRound
                    self.delegate?.accountManager(self, didWaitForNext: round)
                    self.fetchAllAccounts(isVerifiedAssetsIncluded: false) {
                        completion?(round)
                    }
                case .failure:
                    self.getTransactionParamsAndFetchAccounts(completion: completion)
                }
            }
        } else {
            getTransactionParamsAndFetchAccounts(completion: completion)
        }
    }
    
    private func getTransactionParamsAndFetchAccounts(completion: ((Int64?) -> Void)?) {
        api.getTransactionParams { response in
            switch response {
            case .failure:
                self.waitForNextRoundAndFetchAccounts(round: 0, completion: completion)
            case let .success(params):
                self.params = params
                self.currentRound = params.lastRound
            }
            
            guard let round = self.currentRound else {
                completion?(nil)
                return
            }
            
            self.api.waitRound(with: WaitRoundDraft(round: round)) { roundDetailResponse in
                switch roundDetailResponse {
                case let .success(result):
                    let round = result.lastRound
                    self.delegate?.accountManager(self, didWaitForNext: round)
                    self.fetchAllAccounts(isVerifiedAssetsIncluded: false) {
                        completion?(round)
                    }
                case .failure:
                    completion?(nil)
                }
            }
        }
    }
}

protocol AccountManagerDelegate: AnyObject {
    func accountManager(_ accountManager: AccountManager, didWaitForNext round: Int64?)
}
