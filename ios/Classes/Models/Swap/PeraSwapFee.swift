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

//   PeraSwapFee.swift

import Foundation
import MagpieCore

final class PeraSwapFee: ALGEntityModel {
    let fee: UInt64?

    init(
        _ apiModel: APIModel = APIModel()
    ) {
        self.fee = apiModel.peraFeeAmount.unwrap { UInt64($0) }
    }

    func encode() -> APIModel {
        var apiModel = APIModel()
        apiModel.peraFeeAmount = fee.unwrap { String(describing: $0) } 
        return apiModel
    }
}

extension PeraSwapFee {
    struct APIModel: ALGAPIModel {
        var peraFeeAmount: String?

        init() {
            self.peraFeeAmount = nil
        }

        private enum CodingKeys:
            String,
            CodingKey {
            case peraFeeAmount = "pera_fee_amount"
        }
    }
}
