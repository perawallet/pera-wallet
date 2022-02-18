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
//  AlgorandAppStoreReviewer.swift

import Foundation

class AlgorandAppStoreReviewer: AppStoreReviewer {
    
    private let appReviewTriggerCount = 20
    
    func startAppStoreReviewRequestContidition() {
        let openAppCount = UserDefaults.standard.integer(forKey: AppStoreReviewKeys.reviewConditionKey.rawValue) + 1
        UserDefaults.standard.set(openAppCount, forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
    }
    
    func canAskForAppStoreReview() -> Bool {
        let appOpenCount = UserDefaults.standard.integer(forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
        return appOpenCount == appReviewTriggerCount
    }
    
    func updateAppStoreReviewConditionAfterRequest() {
        UserDefaults.standard.set(0, forKey: AppStoreReviewKeys.reviewConditionKey.rawValue)
    }
}
