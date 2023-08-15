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

//   InsufficientAlgoBalanceScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class InsufficientAlgoBalanceScreen:
    MacaroonUIKit.ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return determinePreferredStatusBarStyle(for: api?.network ?? .mainnet)
    }

    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var imageView = UIImageView()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    private lazy var algoItemView = PrimaryListItemView()
    private lazy var actionView = MacaroonUIKit.Button()

    private lazy var theme = InsufficientAlgoBalanceScreenTheme()

    private let draft: InsufficientAlgoBalanceDraft

    typealias EventHandler = (Event) -> Void
    private let eventHandler: EventHandler
    
    var api: ALGAPI?

    init(
        draft: InsufficientAlgoBalanceDraft,
        eventHandler: @escaping EventHandler,
        api: ALGAPI?
    ) {
        self.draft = draft
        self.eventHandler = eventHandler
        self.api = api
        
        super.init()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode =  .never
    }

    override func prepareLayout() {
        super.prepareLayout()

        addContext()
        addAction()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.3, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension InsufficientAlgoBalanceScreen {
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == theme.contextEdgeInsets.bottom
        }

        addImage()
        addTitle()
        addBody()
        addAlgoItemView()
    }

    private func addImage() {
        imageView.customizeAppearance(theme.image)

        imageView.fitToIntrinsicSize()
        contextView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindImage()
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        titleView.fitToIntrinsicSize()
        contextView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == imageView.snp.bottom + theme.titleTopInset
            $0.leading == 0
            $0.trailing == 0
        }

        bindTitle()
    }

    private func addBody() {
        contextView.addSubview(bodyView)
        bodyView.customizeAppearance(theme.body)

        bodyView.contentEdgeInsets.top = theme.spacingBetweenTitleAndBody
        bodyView.fitToIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }

        bindBody()
    }

    private func addAlgoItemView() {
        let canvasView = MacaroonUIKit.BaseView()
        canvasView.draw(border: theme.algoItemBorder)
        canvasView.draw(corner: theme.algoItemCorner)

        contextView.addSubview(canvasView)
        canvasView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndAlgoItem
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        algoItemView.customize(theme.algoItem)

        canvasView.addSubview(algoItemView)
        algoItemView.snp.makeConstraints {
            $0.setPaddings(theme.algoItemContentPaddings)
        }

        bindAlgoItem()
    }

    private func addAction() {
        actionView.customizeAppearance(theme.action)
        actionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        footerView.addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.top == theme.actionEdgeInsets.top
            $0.leading == theme.actionEdgeInsets.leading
            $0.trailing == theme.actionEdgeInsets.trailing
            $0.bottom == theme.actionEdgeInsets.bottom
        }

        actionView.addTouch(
            target: self,
            action: #selector(performAction)
        )

        bindAction()
    }
}

extension InsufficientAlgoBalanceScreen {
    @objc
    private func performAction() {
        eventHandler(.performAction)
    }
}

extension InsufficientAlgoBalanceScreen {
    private func bindImage() {
        imageView.image = "icon-info-red".uiImage
    }

    private func bindTitle() {
        titleView.attributedText =
            "required-min-balance-title"
                .localized
                .bodyLargeMedium(alignment: .center)
    }

    private func bindBody() {
        bodyView.attributedText =
            "required-min-balance-description"
                .localized
                .bodyRegular(alignment: .center)
    }

    private func bindAlgoItem() {
        algoItemView.bindData(AssetListItemViewModel(draft.algoAssetItem))
    }

    private func bindAction() {
        actionView.editTitle = .string("title-got-it".localized)
    }
}

extension InsufficientAlgoBalanceScreen {
    enum Event {
        case performAction
    }
}
