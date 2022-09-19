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
//   BlockingLoadingController.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol LoadingController {
    func startLoadingWithMessage(_ title: String)
    func startLoadingWithMessage(_ attributedTitle: NSAttributedString)
    func stopLoading()
    func stopLoadingAfter(seconds: Double, on queue: DispatchQueue, execute: @escaping () -> Void)
}

final class BlockingLoadingController: MacaroonUIKit.BlockingLoadingController, LoadingController {
    init(presentingView: UIView) {
        super.init(presentingView: presentingView)

        configuration.chromeStyle = [
            .backgroundColor(Colors.Backdrop.modalBackground.uiColor)
        ]
        configuration.loadingIndicatorClass = ScreenLoadingIndicator.self
    }

    func startLoadingWithMessage(_ title: String) {
        super.startLoading()

        setTitle(title)
    }

    func startLoadingWithMessage(_ attributedTitle: NSAttributedString) {
        super.startLoading()

        setAttributedTitle(attributedTitle)
    }

    func stopLoadingAfter(seconds: Double, on queue: DispatchQueue = .main, execute: @escaping () -> Void) {
        let time: DispatchTime = .now() + seconds
        queue.asyncAfter(deadline: time) {
            self.stopLoading()
            execute()
        }
    }
}

extension BlockingLoadingController {
    private func setTitle(_ title: String) {
        if let screenLoadingIndicator = loadingIndicator as? ScreenLoadingIndicator {
            screenLoadingIndicator.title = title
        }
    }

    private func setAttributedTitle(_ attributedTitle: NSAttributedString) {
        if let screenLoadingIndicator = loadingIndicator as? ScreenLoadingIndicator {
            screenLoadingIndicator.attributedTitle = attributedTitle
        }
    }
}
