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
//  RewardViewModel.swift

import Foundation
import MacaroonUIKit

struct RewardViewModel:
    PairedViewModel,
    Hashable {
    private(set) var amountViewModel: TransactionAmountViewModel?
    private(set) var date: String?
    
    init(
        _ reward: Reward
    ) {
        bindAmountViewModel(reward)
        bindDate(reward)
    }
}

extension RewardViewModel {
    private mutating func bindAmountViewModel(_ reward: Reward) {
        amountViewModel = TransactionAmountViewModel(.positive(amount: reward.amount.toAlgos))
    }

    private mutating func bindDate(_ reward: Reward) {
        date = reward.date?.toFormat("MMMM dd, yyyy")
    }
}
