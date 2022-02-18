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
//   RewardCalculator.swift

import UIKit

final class RewardCalculator {

    weak var delegate: RewardCalculatorDelegate?

    private let api: ALGAPI
    private var account: Account

    private var totalSupply: UInt64?
    private var rewardRate: UInt64?
    private var rewardResidue: UInt64?

    private var currentRound: BlockRound
    private let sharedDataController: SharedDataController

    private let rewardsDispatchGroup = DispatchGroup()

    init(api: ALGAPI, account: Account, sharedDataController: SharedDataController) {
        self.api = api
        self.account = account
        self.sharedDataController = sharedDataController

        if let lastRound = sharedDataController.lastRound {
            currentRound = lastRound
        } else {
            currentRound = 0
        }

        sharedDataController.add(self)
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

extension RewardCalculator: SharedDataControllerObserver {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning:
            guard let currentRound = sharedDataController.lastRound else {
                return
            }

            self.currentRound = currentRound
            // After each new block, get the required calculation values again and calculate pending rewards
            calculatePendingRewards()
        default:
            break
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
        delegate?.rewardCalculator(self, didCalculate: getPendingRewards() / Decimal(algosInMicroAlgos))
    }

    private func getPendingRewards() -> Decimal {
        guard let rewardResidue = rewardResidue,
              let rewardRate = rewardRate,
              let totalSupply = totalSupply else {
            return 0
        }

        return account.amountWithoutRewards.toAlgos * (Decimal(rewardResidue + rewardRate)) / totalSupply.toAlgos
    }
}

protocol RewardCalculatorDelegate: AnyObject {
    func rewardCalculator(_ rewardCalculator: RewardCalculator, didCalculate rewards: Decimal)
}
