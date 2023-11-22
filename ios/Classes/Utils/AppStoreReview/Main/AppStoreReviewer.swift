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
//  AppStoreReviewer.swift

import StoreKit

protocol AppStoreReviewer: AnyObject {
    typealias APPID = String
    
    func requestReviewIfAppropriate()
    func requestManualReview(forAppWith id: APPID)
    
    func startAppStoreReviewRequestContidition()
    func canAskForAppStoreReview() -> Bool
    func updateAppStoreReviewConditionAfterRequest()
}

extension AppStoreReviewer {
    func requestReviewIfAppropriate() {
        guard let scene = UIApplication.shared.windowScene else {
            return
        }

        startAppStoreReviewRequestContidition()

        if !isCurrentVersionAskedForAppStoreReview() && canAskForAppStoreReview() {
            SKStoreReviewController.requestReview(in: scene)
            updateLatestVersionForAppStoreReview()
            updateAppStoreReviewConditionAfterRequest()
        }
    }
    
    func requestManualReview(forAppWith id: APPID) {
        if let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(id)?action=write-review") {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}

extension AppStoreReviewer {
    /// <note> App review prompt should not be displayed to the user more than one time for the same app version.
    private func isCurrentVersionAskedForAppStoreReview() -> Bool {
        if let currentAppVersion = getCurrentAppVersion(),
           let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: AppStoreReviewKeys.lastVersionKey.rawValue) {
            return currentAppVersion == lastVersionPromptedForReview
        }
        
        return false
    }
    
    private func updateLatestVersionForAppStoreReview() {
        if let currentAppVersion = getCurrentAppVersion() {
            UserDefaults.standard.set(currentAppVersion, forKey: AppStoreReviewKeys.lastVersionKey.rawValue)
        }
    }
    
    private func getCurrentAppVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

enum AppStoreReviewKeys: String {
    case reviewConditionKey = "review.condition.value"
    case lastVersionKey = "last.version.reviewed"
}
