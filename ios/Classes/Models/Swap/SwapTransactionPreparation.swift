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

//   SwapTransactionPreparation.swift

import Foundation

final class SwapTransactionPreparation: ALGEntityModel {
    let transactionGroups: [SwapTransactionGroup]

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.transactionGroups = apiModel.transactionGroups.unwrapMap(SwapTransactionGroup.init)
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.transactionGroups = transactionGroups.map { $0.encode() }
        return apiModel
    }
}

extension SwapTransactionPreparation {
    struct APIModel: ALGAPIModel {
        var transactionGroups: [SwapTransactionGroup.APIModel]?

        init() {
            self.transactionGroups = []
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case transactionGroups =  "transaction_groups"
        }
    }
}
