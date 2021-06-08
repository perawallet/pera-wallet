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
//   TransactionTutorialViewModel.swift

import UIKit

class TransactionTutorialViewModel {
    private(set) var subtitle: String?
    private(set) var secondTip: NSAttributedString?
    private(set) var tapToMoreText: NSAttributedString?
    private(set) var animationName: String?

    init(isInitialDisplay: Bool) {
        setSubtitle(from: isInitialDisplay)
        setSecondTip()
        setTapToMoreText()
        setAnimationName()
    }

    private func setSubtitle(from isInitialDisplay: Bool) {
        subtitle = isInitialDisplay ? "transaction-tutorial-subtitle".localized : "transaction-tutorial-subtitle-other".localized
    }

    private func setSecondTip() {
        secondTip = "transaction-tutorial-tip-second".localized.addAttributes(
            [.foregroundColor: Colors.General.unknown],
            to: "transaction-tutorial-tip-second-highlighted".localized
        )
    }

    private func setTapToMoreText() {
        tapToMoreText = "transaction-tutorial-tap-to-more".localized.addAttributes(
            [
                .foregroundColor: Colors.Text.link,
                .font: UIFont.font(withWeight: .medium(size: 14.0))
            ],
            to: "transaction-tutorial-tap-to-more-highlighted".localized
        )
    }

    private func setAnimationName() {
        animationName = UIApplication.shared.isDarkModeDisplay ? "account_animation_dark" : "account_animation"
    }
}
