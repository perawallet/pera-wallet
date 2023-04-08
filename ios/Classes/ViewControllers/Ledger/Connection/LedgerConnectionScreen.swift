// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   LedgerConnectionScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class LedgerConnectionScreen:
    MacaroonUIKit.ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var imageView = LottieImageView()
    private lazy var titleView = UILabel()
    private lazy var bodyView = UILabel()
    private lazy var actionView = MacaroonUIKit.Button()

    private lazy var theme = LedgerConnectionScreenTheme()

    typealias EventHandler = (Event) -> Void
    private let eventHandler: EventHandler

    init(
        eventHandler: @escaping EventHandler
    ) {
        self.eventHandler = eventHandler
        super.init()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startAnimatingImage()
    }

    override func viewDidChangePreferredUserInterfaceStyle() {
        super.viewDidChangePreferredUserInterfaceStyle()

        updateImageWhenViewDidChangePreferredUserInterfaceStyle()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addContext()
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

extension LedgerConnectionScreen {
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
        addAction()
    }

    private func addImage() {
        contextView.addSubview(imageView)

        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindImage()
    }

    private func addTitle() {
        contextView.addSubview(titleView)
        titleView.customizeAppearance(theme.title)

        titleView.fitToIntrinsicSize()
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

        bodyView.fitToIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        bindBody()
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

extension LedgerConnectionScreen {
    func startAnimatingImage() {
        imageView.play(with: LottieImageView.Configuration())
    }

    func stopAnimatingImage() {
        imageView.stop()
    }
}

extension LedgerConnectionScreen {
    private func updateImageWhenViewDidChangePreferredUserInterfaceStyle() {
        bindImage()
        startAnimatingImage()
    }
}

extension LedgerConnectionScreen {
    @objc
    private func performAction() {
        eventHandler(.performCancel)
    }
}

extension LedgerConnectionScreen {
    private func bindImage() {
        let animation =
            traitCollection.userInterfaceStyle == .dark
            ? "dark-ledger"
            : "light-ledger"
        imageView.setAnimation(animation)
    }

    private func bindTitle() {
        titleView.attributedText =
            "ledger-approval-connection-title"
                .localized
                .bodyLargeMedium(alignment: .center)
    }

    private func bindBody() {
        bodyView.attributedText =
            "ledger-approval-connection-message"
                .localized
                .bodyRegular(alignment: .center)
    }

    private func bindAction() {
        actionView.editTitle = .string("title-cancel".localized)
    }
}

extension LedgerConnectionScreen {
    enum Event {
        case performCancel
    }
}
