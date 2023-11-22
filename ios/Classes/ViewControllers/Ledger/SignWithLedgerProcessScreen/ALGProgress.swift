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

//   ALGProgress.swift

import Foundation

final class ALGProgress {
    let totalUnitCount: Int
    var currentUnitCount: Int

    init(
        totalUnitCount: Int,
        currentUnitCount: Int = 1
    ) {
        self.totalUnitCount = totalUnitCount
        self.currentUnitCount = currentUnitCount
    }

    var fractionCompleted: Float {
        return Float(currentUnitCount) / Float(totalUnitCount)
    }

    var isFinished: Bool {
        return currentUnitCount == totalUnitCount + 1
    }

    var isSingular: Bool {
        return totalUnitCount == 1
    }

    func callAsFunction() {
        if isFinished {
            assertionFailure("Progress has already been completed.")
            return
        }

        currentUnitCount += 1
    }
}
