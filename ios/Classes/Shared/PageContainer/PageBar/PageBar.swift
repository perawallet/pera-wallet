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
//   PageBar.swift

import Foundation
import MacaroonUIKit
import SnapKit
import UIKit

final class PageBar: View {
    var items: [PageBarButtonItem] = [] {
        didSet { updateLayoutWhenItemsDidChange() }
    }
    var itemDidSelect: ((Int) -> Void)?

    var selectedPage: Int? {
        return selectedBarButton.unwrap {
            barButtons.firstIndex(of: $0)
        }
    }

    override var intrinsicContentSize: CGSize {
        return intrinsicHeight.unwrap({
            CGSize((UIView.noIntrinsicMetric, $0))
        }, or: super.intrinsicContentSize
        )
    }

    private lazy var contentView = HStackView()
    private lazy var offIndicatorView = UIView()
    private lazy var onIndicatorView = UIView()

    private var barButtons: [PageBarButton] = []
    private var selectedBarButton: PageBarButton? {
        didSet {
            oldValue?.isSelected = false
            selectedBarButton?.isSelected = true
        }
    }

    private var onIndicatorWidthConstraint: Constraint?

    private var intrinsicHeight: LayoutMetric?

    func customizeAppearance(_ styleSheet: PageBarStyleSheet ) {
        customizeOffIndicatorAppearance(styleSheet)
        customizeOnIndicatorAppearance(styleSheet)
    }

    func prepareLayout(_ layoutSheet: PageBarLayoutSheet) {
        addContent(layoutSheet)
        addOffIndicator(layoutSheet)
        addOnIndicator(layoutSheet)

        intrinsicHeight = layoutSheet.intrinsicHeight
        invalidateIntrinsicContentSize()
    }
}

extension PageBar {
    func scrollToItem(at page: Int, animated: Bool) {
        if items.isEmpty {
            return
        }

        guard let barButton = barButtons[safe: page] else {
            return
        }

        selectedBarButton = barButton

        updateLayoutOnScroll(to: barButton.frame.minX, animated: animated)
    }

    func scrollToItem(at point: CGFloat, animated: Bool) {
        if items.isEmpty {
            return
        }

        let leadingPadding = ((point - contentView.frame.minX) / CGFloat(items.count)).ceil()
        let page = Int((leadingPadding / onIndicatorView.bounds.width).rounded())

        selectedBarButton = barButtons[safe: page]

        updateLayoutOnScroll(to: leadingPadding, animated: animated)
    }
}

extension PageBar {
    private func customizeOffIndicatorAppearance(_ styleSheet: PageBarStyleSheet) {
        offIndicatorView.customizeAppearance(styleSheet.offIndicator)
    }

    private func customizeOnIndicatorAppearance(_ styleSheet: PageBarStyleSheet) {
        onIndicatorView.customizeAppearance(styleSheet.onIndicator)
    }
}

extension PageBar {
    private func updateLayoutWhenItemsDidChange() {
        removeBarButtons()
        addBarButtons()

        updateOnIndicatorLayoutWhenItemsDidChange()
        
        layoutIfNeeded()

        // swiftlint:disable force_cast
        barButtons = contentView.arrangedSubviews as! [PageBarButton]
        // swiftlint:enable force_cast
    }

    private func updateLayoutOnScroll(to point: LayoutMetric, animated: Bool) {
        updateOnIndicatorLayoutOnScroll(to: point, animated: animated)
    }

    private func addContent(_ layoutSheet: PageBarLayoutSheet) {
        addSubview(contentView)
        contentView.distribution = .fillEqually
        contentView.snp.makeConstraints {
            $0.setPaddings(
                layoutSheet.contentPaddings
            )
        }
    }

    private func addBarButtons() {
        items.forEach {
            let barButton = PageBarButton(barButtonItem: $0)

            contentView.addArrangedSubview(barButton)

            barButton.addTouch(
                target: self,
                action: #selector(notifyWhenBarButtonWasSelected(_:))
            )
        }
    }

    private func removeBarButtons() {
        contentView.deleteAllArrangedSubviews()
    }

    private func addOffIndicator(_ layoutSheet: PageBarLayoutSheet) {
        addSubview(offIndicatorView)
        offIndicatorView.snp.makeConstraints {
            let horizontalPaddings = layoutSheet.offIndicatorHorizontalPaddings

            $0.fitToHeight(layoutSheet.offIndicatorHeight)
            $0.setPaddings(
                (
                    .noMetric,
                    horizontalPaddings.leading,
                    layoutSheet.onIndicatorBottomPadding,
                    horizontalPaddings.trailing
                )
            )
        }
    }

    private func addOnIndicator(_ layoutSheet: PageBarLayoutSheet) {
        addSubview(onIndicatorView)
        onIndicatorView.snp.makeConstraints {
            $0.leading == contentView.snp.leading
            $0.bottom == layoutSheet.onIndicatorBottomPadding

            $0.fitToSize((.noMetric, layoutSheet.onIndicatorHeight))
        }
    }

    private func updateOnIndicatorLayoutWhenItemsDidChange() {
        onIndicatorWidthConstraint?.deactivate()
        onIndicatorWidthConstraint = nil

        if items.isEmpty {
            return
        }

        onIndicatorView.snp.makeConstraints {
            let multiplier = (1 / CGFloat(items.count)).round(to: 2)

            onIndicatorWidthConstraint = $0.matchToWidth(of: contentView, multiplier: multiplier)
        }
    }

    private func updateOnIndicatorLayoutOnScroll(to point: LayoutMetric, animated: Bool) {
        if onIndicatorView.frame.minX == point {
            return
        }

        onIndicatorView.snp.updateConstraints {
            $0.leading == contentView.snp.leading + point
        }

        if !animated {
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: [],
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension PageBar {
    @objc
    private func notifyWhenBarButtonWasSelected(_ sender: PageBarButton) {
        let foundIndex =
        barButtons.firstIndex(of: sender)

        guard let index = foundIndex else {
            return
        }

        itemDidSelect?(index)
    }
}
