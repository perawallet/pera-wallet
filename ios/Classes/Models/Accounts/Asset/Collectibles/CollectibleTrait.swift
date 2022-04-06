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

//   CollectibleTrait.swift

import Foundation
import MagpieCore
import MacaroonUtils

final class CollectibleTrait: ALGAPIModel {
    let displayName: String?
    let displayValue: String?

    init() {
        self.displayName = nil
        self.displayValue = nil
    }

    private enum CodingKeys:
        String,
        CodingKey {
        case displayName = "display_name"
        case displayValue = "display_value"
    }
}
