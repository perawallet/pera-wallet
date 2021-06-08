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
//  AnimatedTutorialViewModel.swift

import UIKit

class AnimatedTutorialViewModel {
    private(set) var animation: String?
    private(set) var title: String?
    private(set) var description: NSAttributedString?
    private(set) var mainTitle: String?
    private(set) var actionTitle: String?

    init(tutorial: AnimatedTutorial) {
        setAnimation(from: tutorial)
        setTitle(from: tutorial)
        setDescription(from: tutorial)
        setMainTitle(from: tutorial)
        setActionTitle(from: tutorial)
    }

    private func setAnimation(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            animation = "shield_animation"
        case .recover:
            animation = UIApplication.shared.isDarkModeDisplay ? "recover_animation_dark" : "recover_animation_light"
        case .watchAccount:
            animation = "watch_animation"
        case .writePassphrase:
            animation = "pen_animation"
        case .passcode:
            animation = "lock_animation"
        case .localAuthentication:
            animation = "local_auth_animation"
        }
    }

    private func setTitle(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            title = "tutorial-title-back-up".localized
        case .recover:
            title = "tutorial-title-recover".localized
        case .watchAccount:
            title = "title-watch-account".localized
        case .writePassphrase:
            title = "tutorial-title-write".localized
        case .passcode:
            title = "tutorial-title-passcode".localized
        case .localAuthentication:
            title = "local-authentication-preference-title".localized
        }
    }

    private func setDescription(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            description = "tutorial-description-back-up".localized.attributed([.lineSpacing(1.2)])
        case .recover:
            description = "tutorial-description-recover".localized.attributed([.lineSpacing(1.2)])
        case .watchAccount:
            description = addAttributesForWatchAccountDescription()
        case .writePassphrase:
            description = addAttributesForPassphraseDescription()
        case .passcode:
            description = "tutorial-description-passcode".localized.attributed([.lineSpacing(1.2)])
        case .localAuthentication:
            description = "tutorial-description-local".localized.attributed([.lineSpacing(1.2)])
        }
    }

    private func addAttributesForWatchAccountDescription() -> NSAttributedString {
        let fullString = "tutorial-description-watch".localized
        let italicString = "tutorial-description-watch-italic".localized
        let warningString = "tutorial-description-warning-title".localized
        let fullAttributedText = NSMutableAttributedString(string: fullString)
        fullAttributedText.addFont(UIFont.font(withWeight: .lightItalic(size: 16.0)), to: italicString)
        fullAttributedText.addFont(UIFont.font(withWeight: .semiBoldItalic(size: 16.0)), to: warningString)
        fullAttributedText.addColor(Colors.Main.red600, to: italicString)
        fullAttributedText.addLineHeight(1.2)
        return fullAttributedText
    }

    private func addAttributesForPassphraseDescription() -> NSAttributedString {
        let fullString = "tutorial-description-write".localized
        let italicString = "tutorial-description-write-italic".localized
        let warningString = "tutorial-description-warning-title".localized
        let fullAttributedText = NSMutableAttributedString(string: fullString)
        fullAttributedText.addFont(UIFont.font(withWeight: .lightItalic(size: 16.0)), to: italicString)
        fullAttributedText.addFont(UIFont.font(withWeight: .semiBoldItalic(size: 16.0)), to: warningString)
        fullAttributedText.addColor(Colors.Main.red600, to: italicString)
        fullAttributedText.addLineHeight(1.2)
        return fullAttributedText
    }

    private func setMainTitle(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .backUp:
            mainTitle = "tutorial-main-title-back-up".localized
        case .recover:
            mainTitle = "tutorial-main-title-recover".localized
        case .watchAccount:
            mainTitle = "watch-account-create".localized
        case .writePassphrase:
            mainTitle = "tutorial-main-title-write".localized
        case .passcode:
            mainTitle = "tutorial-main-title-passcode".localized
        case .localAuthentication:
            mainTitle = "local-authentication-enable".localized
        }
    }

    private func setActionTitle(from tutorial: AnimatedTutorial) {
        switch tutorial {
        case .passcode:
            actionTitle = "tutorial-action-title-passcode".localized
        case .localAuthentication:
            actionTitle = "local-authentication-no".localized
        default:
            break
        }
    }
}
