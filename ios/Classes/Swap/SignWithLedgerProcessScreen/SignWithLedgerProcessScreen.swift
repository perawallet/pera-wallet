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

//   SignWithLedgerProcessScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class SignWithLedgerProcessScreen:
    MacaroonUIKit.ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    var isProgressFinished: Bool {
        return progress.isFinished
    }

    private lazy var progressView = UIProgressView()
    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var imageView = LottieImageView()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    private lazy var actionView = MacaroonUIKit.Button()

    private lazy var theme = SignWithLedgerProcessScreenTheme()

    private lazy var progress = ALGProgress(totalUnitCount: draft.totalTransactionCount)

    private let transactionSigner: SwapTransactionSigner
    private let draft: SignWithLedgerProcessDraft

    typealias EventHandler = (Event) -> Void
    private let eventHandler: EventHandler

    init(
        transactionSigner: SwapTransactionSigner,
        draft: SignWithLedgerProcessDraft,
        eventHandler: @escaping EventHandler
    ) {
        self.transactionSigner = transactionSigner
        self.draft = draft
        self.eventHandler = eventHandler
        super.init()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode =  .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startAnimatingImage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionSigner.disonnectFromLedger()
    }

    override func viewDidChangePreferredUserInterfaceStyle() {
        super.viewDidChangePreferredUserInterfaceStyle()

        updateImageWhenViewDidChangePreferredUserInterfaceStyle()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addProgress()
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

extension SignWithLedgerProcessScreen {
    func increaseProgress() {
        progress()

        bindProgress(animated: true)
    }
}

extension SignWithLedgerProcessScreen {
    private func addProgress() {
        progressView.progressViewStyle = .bar
        progressView.progressTintColor = theme.progressTintColor.uiColor
        progressView.trackTintColor = theme.trackTintColor.uiColor

        view.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top == theme.progressTopInset
            $0.leading == 0
            $0.trailing == 0
        }

        bindProgress(animated: false)
    }

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

        bodyView.contentEdgeInsets.top = theme.spacingBetweenTitleAndBody
        bodyView.fitToIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
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

extension SignWithLedgerProcessScreen {
    func startAnimatingImage() {
        imageView.play(with: LottieImageView.Configuration())
    }

    func stopAnimatingImage() {
        imageView.stop()
    }
}

extension SignWithLedgerProcessScreen {
    private func updateImageWhenViewDidChangePreferredUserInterfaceStyle() {
        bindImage()
        startAnimatingImage()
    }
}

extension SignWithLedgerProcessScreen {
    @objc
    private func performAction() {
        eventHandler(.performCancelApproval)
    }
}

extension SignWithLedgerProcessScreen {
    private func bindProgress(animated: Bool) {
        title =
            "swap-sign-with-ledger-process-title"
                .localized(params: "\(progress.currentUnitCount)", "\(progress.totalUnitCount)")

        progressView.setProgress(
            progress.fractionCompleted,
            animated: animated
        )
    }

    private func bindImage() {
        let animation =
            traitCollection.userInterfaceStyle == .dark
            ? "dark-ledger"
            : "light-ledger"
        imageView.setAnimation(animation)
    }

    private func bindTitle() {
        titleView.attributedText =
            "ledger-approval-title"
                .localized
                .bodyLargeMedium(alignment: .center)
    }

    private func bindBody() {
        bodyView.attributedText =
            "ledger-approval-sign-message"
                .localized(params: "\(draft.ledgerDeviceName)")
                .bodyRegular(alignment: .center)
    }

    private func bindAction() {
        actionView.editTitle = .string("ledger-approval-cancel-title".localized)
    }
}

extension SignWithLedgerProcessScreen {
    enum Event {
        case performCancelApproval
    }
}
