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
    ListReusable {
    lazy var handlers = Handlers()

    private lazy var contentView = UIView()
    private lazy var resultWithActionContainer = UIView()
    private lazy var resultView = ResultView()
    private lazy var actionView = Button(.imageAtLeft(spacing: 12))
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        setListeners()
    }

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

    func setListeners() {
        actionView.addTarget(self, action: #selector(didTapActionView), for: .touchUpInside)
    }

    func bindData(
        _ viewModel: NoContentWithActionViewModel?
    ) {
        resultView.bindData(viewModel)
        actionView.setEditTitle(viewModel?.actionTitle, for: .normal)
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
        addAction(theme)
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

    private func addAction(
        _ theme: NoContentViewWithActionTheme
    ) {
        actionView.customizeAppearance(theme.action)

        resultWithActionContainer.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == resultView.snp.bottom + theme.actionTopMargin
            $0.bottom == 0
        }

        alignAction(actionView, for: theme.actionAlignment)

        actionView.draw(corner: Corner(radius: theme.actionCornerRadius))
    }

    private func alignAction(
        _ action: MacaroonUIKit.Button,
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
    @objc
    private func didTapActionView() {
        handlers.didTapActionView?()
    }
}

extension NoContentWithActionView {
    struct Handlers {
        var didTapActionView: EmptyHandler?
    }
}
