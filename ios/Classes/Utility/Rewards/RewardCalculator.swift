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
//   RewardCalculator.swift

import UIKit

class RewardCalculator {

    weak var delegate: RewardCalculatorDelegate?

    private let api: AlgorandAPI
    private var account: Account

    private var totalSupply: Int64?
    private var rewardRate: Int64?
    private var rewardResidue: Int64?

    private var currentRound: Int64

    private let rewardsDispatchGroup = DispatchGroup()

    init(api: AlgorandAPI, account: Account) {
        self.api = api
        self.account = account

        // Listen waiting for next block from the account manager to get the current round
        if let accountManager = UIApplication.shared.accountManager {
            self.currentRound = accountManager.currentRound ?? 0
            accountManager.delegate = self
        } else {
            currentRound = 0
        }
    }

    func updateAccount(_ account: Account) {
        self.account = account
    }

    private func calculatePendingRewards() {
        getTotalSupply()
        getCurrentBlock()
        calculateAndUpdatePendingRewards()
    }
}

extension RewardCalculator {
    private func getTotalSupply() {
        rewardsDispatchGroup.enter()

        api.getTotalSupply { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(supply):
                self.totalSupply = supply.totalMoney
            case .failure:
                break
            }

            self.rewardsDispatchGroup.leave()
        }
    }

    private func getCurrentBlock() {
        rewardsDispatchGroup.enter()

        api.getBlock(currentRound) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .success(block):
                self.rewardRate = block.rewardsRate
                self.rewardResidue = block.rewardsResidue
            case .failure:
                break
            }

            self.rewardsDispatchGroup.leave()
        }
    }
}

extension RewardCalculator {
    private func calculateAndUpdatePendingRewards() {
        rewardsDispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }

            self.updatePendingRewards()
        }
    }

    private func updatePendingRewards() {
        delegate?.rewardCalculator(self, didCalculate: getPendingRewards() / Double(algosInMicroAlgos))
    }

    private func getPendingRewards() -> Double {
        guard let rewardResidue = rewardResidue,
              let rewardRate = rewardRate,
              let totalSupply = totalSupply else {
            return 0
        }

        return account.amountWithoutRewards.toAlgos * (Double(rewardResidue + rewardRate)) / totalSupply.toAlgos
    }
}

extension RewardCalculator: AccountManagerDelegate {
    func accountManager(_ accountManager: AccountManager, didWaitForNext round: Int64?) {
        guard let currentRound = round else {
            return
        }

        self.currentRound = currentRound
        // After each new block, get the required calculation values again and calculate pending rewards
        calculatePendingRewards()
    }
}

protocol RewardCalculatorDelegate: AnyObject {
    func rewardCalculator(_ rewardCalculator: RewardCalculator, didCalculate rewards: Double)
}
