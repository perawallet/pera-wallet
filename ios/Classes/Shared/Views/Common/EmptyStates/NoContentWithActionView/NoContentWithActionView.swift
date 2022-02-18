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
    private lazy var resultView = ResultView()
    private lazy var actionView = Button()
    
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
            $0.setVerticalPaddings((theme.contentVerticalPadding, theme.contentVerticalPadding))
        }

        addResult(theme)
        addAction(theme)
    }

    private func addResult(
        _ theme: NoContentViewWithActionTheme
    ) {
        resultView.customize(theme)

        contentView.addSubview(resultView)
        resultView.snp.makeConstraints {
            $0.center == 0
            
            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }
    }

    private func addAction(
        _ theme: NoContentViewWithActionTheme
    ) {
        actionView.customizeAppearance(theme.action)

        contentView.addSubview(actionView)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        actionView.snp.makeConstraints {
            $0.top == resultView.snp.bottom + theme.actionTopMargin
            $0.centerX == resultView
            $0.bottom <= 0
            $0.trailing <= 0
            $0.leading >= 0
        }

        actionView.draw(corner: Corner(radius: theme.actionCornerRadius))
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
