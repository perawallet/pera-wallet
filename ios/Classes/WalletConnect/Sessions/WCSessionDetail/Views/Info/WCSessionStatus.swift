// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionStatus.swift

import Foundation

enum WCSessionStatus {
    case idle
    case pinging(progress: ALGProgress)
    case active
    case failed
}

extension WCSessionStatus {
    var isIdle: Bool {
        if case .idle = self {
            return true
        }

        return false
    }

    var isPinging: Bool {
        if case .pinging = self {
            return true
        }

        return false
    }
}
