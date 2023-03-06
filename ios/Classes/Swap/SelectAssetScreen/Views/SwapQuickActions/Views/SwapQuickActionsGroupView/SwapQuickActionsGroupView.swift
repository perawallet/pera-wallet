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

//   SwapQuickActionsGroupView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SwapQuickActionsGroupView: MacaroonUIKit.BaseView {
    typealias Selector = (Int) -> Void

    var selector: Selector?

    private lazy var backgroundView = UIImageView()
    private lazy var contentView = HStackView()

    private var actionViews: [UIView] {
        return contentView.arrangedSubviews
    }

    private let divider: ImageStyle

    init(_ theme: SwapQuickActionsGroupViewTheme = .init()) {
        self.divider = theme.divider
        super.init(frame: .zero)

        addUI(theme)
    }

    func bind(_ viewModel: SwapQuickActionsGroupViewModel?) {
        removeAllActions()
        viewModel?.actionItems.forEach(addAction)
    }
}

extension SwapQuickActionsGroupView {
    private func addUI(_ theme: SwapQuickActionsGroupViewTheme) {
        addBackground(theme)
        addContent(theme)
    }

    private func addBackground(_ theme: SwapQuickActionsGroupViewTheme) {
        backgroundView.customizeAppearance(theme.background)

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addContent(_ theme: SwapQuickActionsGroupViewTheme) {
        addSubview(contentView)
        contentView.spacing = theme.divider.image?.uiImage.width ?? 0
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addAction(_ item: SwapQuickActionItem) {
        addActionDividerIfNeeded()

        let view = MacaroonUIKit.Button(item.layout)

        view.customizeAppearance(item.style)

        contentView.addArrangedSubview(view)
        view.contentEdgeInsets = item.contentEdgeInsets

        view.isEnabled = item.isEnabled

        view.addTouch(
            target: self,
            action: #selector(notifySelectorForSelectedAction)
        )
    }

    private func addActionDividerIfNeeded() {
        guard let lastActionView = actionViews.last else { return }

        let view = UIImageView()

        view.customizeAppearance(divider)

        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.height <= self
            $0.centerY == 0
            $0.leading == lastActionView.snp.trailing
        }
    }

    private func removeAllActions() {
        contentView.deleteAllSubviews()
    }
}

extension SwapQuickActionsGroupView {
    func setActionsEnabled(_ isEnabled: Bool) {
        actionViews.forEach {
            let button = $0 as! MacaroonUIKit.Button
            button.isEnabled = isEnabled
        }
    }
}

extension SwapQuickActionsGroupView {
    @objc
    private func notifySelectorForSelectedAction(_ view: UIView) {
        guard let index = actionViews.firstIndex(of: view) else { return }
        selector?(index)
    }
}
