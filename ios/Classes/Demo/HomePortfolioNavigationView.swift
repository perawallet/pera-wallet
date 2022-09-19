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

//   HomePortfolioNavigationView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomePortfolioNavigationView: View {
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()

    private var isVisible = false
    private var runningVisibilityAnimator: UIViewPropertyAnimator?

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {
        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        subtitleView.customizeBaseAppearance(textColor: Colors.Text.gray)

        addSubview(subtitleView)
        subtitleView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        setTitleVisible(false)
    }

    func bind(
        _ viewModel: HomePortfolioNavigationViewModel?
    ) {
        if let primaryValue = viewModel?.primaryValue {
            primaryValue.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let secondaryValue = viewModel?.secondaryValue {
            secondaryValue.load(in: subtitleView)
        } else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
        }
    }

    func animateTitleVisible(
        _ visible: Bool
    ) {
        if visible == isVisible {
            return
        }

        isVisible = visible

        if let runningVisibilityAnimator = runningVisibilityAnimator,
           runningVisibilityAnimator.isRunning {
            runningVisibilityAnimator.isReversed.toggle()
            return
        }

        if isVisible {
            showTitleAnimated()
        } else {
            hideTitleAnimated()
        }
    }

    private func showTitleAnimated() {
        runningVisibilityAnimator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                [unowned self] in
                self.setTitleVisible(true)
            },
            completion: { [weak self] position in
                guard let self = self else { return }

                switch position {
                case .start:
                    self.setTitleVisible(false)
                case .end:
                    self.isVisible = true
                default:
                    break
                }
            }
        )
    }

    private func hideTitleAnimated() {
        runningVisibilityAnimator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                [unowned self] in
                self.setTitleVisible(false)
            },
            completion: { [weak self] position in
                guard let self = self else { return }

                switch position {
                case .start:
                    self.setTitleVisible(true)
                case .end:
                    self.isVisible = false
                default:
                    break
                }
            }
        )
    }

    private func setTitleVisible(
        _ visible: Bool
    ) {
        titleView.alpha = isVisible ? 1 : 0
        subtitleView.alpha = isVisible ? 1 : 0
    }
}
