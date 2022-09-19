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
//   NoContentWithActionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NoContentWithActionView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performPrimaryAction: TargetActionInteraction(),
        .performSecondaryAction: TargetActionInteraction()
    ]

    private lazy var contentView = UIView()
    private lazy var resultWithActionContainer = UIView()
    private lazy var resultView = ResultView()
    private lazy var actionContentView = MacaroonUIKit.VStackView()
    private lazy var primaryActionCanvasView = MacaroonUIKit.BaseView()
    private lazy var primaryActionView = Button(.imageAtLeft(spacing: 12))
    private lazy var secondaryActionView = Button(.imageAtLeft(spacing: 12))

    func customize(
        _ theme: NoContentViewWithActionTheme
    ) {
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: NoContentWithActionViewModel?
    ) {
        resultView.bindData(viewModel)

        let primaryAction = viewModel?.primaryAction
        primaryActionCanvasView.isHidden = primaryAction == nil
        primaryActionView.setEditTitle(primaryAction?.title, for: .normal)
        primaryActionView.setImage(primaryAction?.image?.template, for: .normal)

        let secondaryAction = viewModel?.secondaryAction
        secondaryActionView.isHidden = secondaryAction == nil
        secondaryActionView.setEditTitle(secondaryAction?.title, for: .normal)
        secondaryActionView.setImage(secondaryAction?.image?.template, for: .normal)
    }

    class func calculatePreferredSize(
        _ viewModel: NoContentWithActionViewModel?,
        for theme: NoContentViewWithActionTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let resultSize = ResultView.calculatePreferredSize(
            viewModel,
            for: theme,
            fittingIn: size
        )

        let buttonHeight = 52.cgFloat

        var preferredHeight =
        resultSize.height +
        theme.contentVerticalPaddings.top +
        theme.contentVerticalPaddings.bottom

        if viewModel.primaryAction != nil {
            preferredHeight += (theme.primaryActionTopMargin + buttonHeight)
        }

        if viewModel.secondaryAction != nil {
            preferredHeight += (theme.secondaryActionTopMargin + buttonHeight)
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension NoContentWithActionView {
    private func addContent(
        _ theme: NoContentViewWithActionTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.height <= snp.height

            $0.setHorizontalPaddings(theme.contentHorizontalPaddings)
            $0.setVerticalPaddings(theme.contentVerticalPaddings)
        }

        addResultWithActionContainer(theme)
    }

    private func addResultWithActionContainer(
        _ theme: NoContentViewWithActionTheme
    ) {
        contentView.addSubview(resultWithActionContainer)
        resultWithActionContainer.snp.makeConstraints {
            $0.bottom <= 0
            $0.center == 0

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }

        addResult(theme)
        addActionContent(theme)
    }

    private func addResult(
        _ theme: NoContentViewWithActionTheme
    ) {
        resultView.customize(theme)

        resultWithActionContainer.addSubview(resultView)
        resultView.snp.makeConstraints {
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }

    private func addActionContent(
        _ theme: NoContentViewWithActionTheme
    ) {
        actionContentView.spacing = theme.secondaryActionTopMargin
        actionContentView.alignment = .center

        resultWithActionContainer.addSubview(actionContentView)
        actionContentView.snp.makeConstraints {
            $0.top == resultView.snp.bottom
            $0.setPaddings((.noMetric, 0, 0, 0))
        }

        addPrimaryAction(theme)
        addSecondaryAction(theme)
    }

    private func addPrimaryAction(
        _ theme: NoContentViewWithActionTheme
    ) {
        actionContentView.addArrangedSubview(primaryActionCanvasView)

        alignAction(primaryActionCanvasView, for: theme.actionAlignment)

        primaryActionCanvasView.addSubview(primaryActionView)

        primaryActionView.snp.makeConstraints {
            $0.setPaddings((theme.primaryActionTopMargin, 0, 0, 0))
        }

        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.adjustsImageWhenHighlighted = false

        primaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        primaryActionView.fitToIntrinsicSize()

        primaryActionView.draw(corner: Corner(radius: theme.actionCornerRadius))

        startPublishing(
            event: .performPrimaryAction,
            for: primaryActionView
        )
    }

    private func addSecondaryAction(
        _ theme: NoContentViewWithActionTheme
    ) {
        secondaryActionView.customizeAppearance(theme.secondaryAction)
        secondaryActionView.adjustsImageWhenHighlighted = false

        actionContentView.addArrangedSubview(secondaryActionView)
        secondaryActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        secondaryActionView.fitToIntrinsicSize()

        alignAction(secondaryActionView, for: theme.actionAlignment)

        secondaryActionView.draw(corner: Corner(radius: theme.actionCornerRadius))

        startPublishing(
            event: .performSecondaryAction,
            for: secondaryActionView
        )
    }

    private func alignAction(
        _ action: UIView,
        for alignment: ActionViewAlignment
    ) {
        switch alignment {
        case .centered:
            action.snp.makeConstraints {
                $0.centerX == resultView
                $0.trailing <= 0
                $0.leading >= 0
            }
        case let .aligned(left, right):
            action.snp.makeConstraints {
                $0.trailing == right
                $0.leading == left
            }
        }
    }
}

extension NoContentWithActionView {
    enum ActionViewAlignment {
        case centered
        case aligned(
            `left`: LayoutMetric,
            `right`: LayoutMetric
        )
    }
}

extension NoContentWithActionView {
    enum Event {
        case performPrimaryAction
        case performSecondaryAction
    }
}
