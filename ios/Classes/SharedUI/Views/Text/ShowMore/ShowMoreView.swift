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

//   ShowMoreView.swift

import Foundation
import MacaroonUIKit
import UIKit
import ActiveLabel

/// <todo>
/// Let's find a better name.
final class ShowMoreView:
    View,
    ViewModelBindable {
    weak var delegate: ShowMoreViewDelegate?

    private lazy var titleView = Label()
    private lazy var bodyView = ALGActiveLabel()
    private lazy var fullBodyView = UILabel()
    private lazy var truncatedBodyView = UILabel()
    private lazy var toggleTruncationActionView = MacaroonUIKit.Button()

    private var theme: ShowMoreViewTheme?

    func customize(_ theme: ShowMoreViewTheme) {
        self.theme = theme

        addTitle(theme)
        addBody(theme)
        addToggleTruncationAction(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: ShowMoreViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let body = viewModel?.body {
            body.load(in: bodyView)
            body.load(in: fullBodyView)
            body.load(in: truncatedBodyView)
        } else {
            bodyView.text = nil
            bodyView.attributedText = nil

            fullBodyView.text = nil
            fullBodyView.attributedText = nil

            truncatedBodyView.text = nil
            truncatedBodyView.attributedText = nil
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty { return }

        updateWhenViewDidLayoutSubviews()
    }
}

extension ShowMoreView {
    private func updateWhenViewDidLayoutSubviews() {
        updateToggleTruncationActionWhenViewDidLayoutSubviews()
    }

    private func updateWhenToggleTruncationDidChange() {
        updateBodyWhenToggleTruncationDidChange()
    }

    private func addTitle(_ theme: ShowMoreViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.contentEdgeInsets.bottom = theme.spacingBetweenTitleAndBody
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addBody(_ theme: ShowMoreViewTheme) {
        bodyView.customize { label in
            label.customizeAppearance(theme.body)
            label.customizeBaseAppearance(textOverflow: theme.truncatedBodyOverflow)
            label.enabledTypes = [.url]
            label.URLColor = theme.bodyURLColor.uiColor
            label.handleURLTap {
                [unowned self] url in
                self.delegate?.showMoreViewDidTapURL(self, url: url)
            }
        }

        addSubview(bodyView)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }

        bodyView.delegate = self

        fullBodyView.customizeBaseAppearance(textOverflow: theme.fullBodyOverflow)

        insertSubview(
            fullBodyView,
            belowSubview: bodyView
        )
        fullBodyView.fitToVerticalIntrinsicSize()
        fullBodyView.snp.makeConstraints {
            $0.top == bodyView
            $0.leading == bodyView
            $0.trailing == bodyView
        }
        fullBodyView.isHidden = true

        truncatedBodyView.customizeBaseAppearance(textOverflow: theme.truncatedBodyOverflow)

        insertSubview(
            truncatedBodyView,
            belowSubview: fullBodyView
        )
        truncatedBodyView.fitToVerticalIntrinsicSize()
        truncatedBodyView.snp.makeConstraints {
            $0.top == bodyView
            $0.leading == bodyView
            $0.trailing == bodyView
        }
        truncatedBodyView.isHidden = true
    }

    private func updateBodyWhenToggleTruncationDidChange() {
        guard let theme = theme else { return }

        let isTruncated = !toggleTruncationActionView.isSelected
        let textOverflow = isTruncated ? theme.truncatedBodyOverflow : theme.fullBodyOverflow
        bodyView.customizeBaseAppearance(textOverflow: textOverflow)
    }

    private func addToggleTruncationAction(_ theme: ShowMoreViewTheme) {
        toggleTruncationActionView.customizeAppearance(theme.toggleTruncationAction)

        addSubview(toggleTruncationActionView)
        toggleTruncationActionView.fitToIntrinsicSize()
        toggleTruncationActionView.contentEdgeInsets = theme.toggleTruncationActionContentEdgeInsets
        toggleTruncationActionView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        toggleTruncationActionView.addTouch(
            target: self,
            action: #selector(toggleBodyTruncation)
        )
    }

    private func updateToggleTruncationActionWhenViewDidLayoutSubviews() {
        let fullBodyHeight = fullBodyView.bounds.height
        let truncatedBodyHeight = truncatedBodyView.bounds.height

        if fullBodyHeight > truncatedBodyHeight {
            if let style = theme?.toggleTruncationAction {
                toggleTruncationActionView.customizeAppearance(style)
            }
        } else {
            toggleTruncationActionView.resetAppearance()
        }
    }
}

extension ShowMoreView {
    @objc
    private func toggleBodyTruncation() {
        toggleTruncationActionView.isSelected.toggle()

        updateWhenToggleTruncationDidChange()
    }
}

extension ShowMoreView: ActiveLabelDelegate {
    func didSelect(_ text: String, type: ActiveType) {
        if type != .url { return }

        guard
            let decodedURLString = text.removingPercentEncoding,
            let urlComponents = URLComponents(string: decodedURLString),
            let url = urlComponents.url
        else {
            return
        }

        delegate?.showMoreViewDidTapURL(self, url: url)
    }
}
protocol ShowMoreViewDelegate: AnyObject {
    func showMoreViewDidTapURL(_ view: ShowMoreView, url: URL)
}
