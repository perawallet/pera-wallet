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
//  RekeyConfirmationView.swift

import UIKit
import MacaroonUIKit

final class RekeyConfirmationView: View {
    weak var delegate: RekeyConfirmationViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var rekeyOldTransitionView = RekeyTransitionItemView()
    private lazy var loadingImage = LottieImageView()
    private lazy var rekeyNewTransitionView = RekeyTransitionItemView()
    private lazy var infoImage = UIImageView()
    private lazy var feeLabel = UILabel()
    private lazy var finalizeButton = Button()

    func setListeners() {
        finalizeButton.addTarget(self, action: #selector(notifyDelegateToFinalizeRekeyConfirmation), for: .touchUpInside)
    }

    func customize(_ theme: RekeyConfirmationViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addTitleLabel(theme)
        addRekeyOldTransitionView(theme)
        addLoadingImage(theme)
        addRekeyNewTransitionView(theme)
        addFinalizeButton(theme)
        addFeeLabel(theme)
        addInfoImage(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension RekeyConfirmationView {
    @objc
    private func notifyDelegateToFinalizeRekeyConfirmation() {
        delegate?.rekeyConfirmationViewDidFinalizeConfirmation(self)
    }
}

extension RekeyConfirmationView {
    private func addTitleLabel(_ theme: RekeyConfirmationViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }

    private func addRekeyOldTransitionView(_ theme: RekeyConfirmationViewTheme) {
        rekeyOldTransitionView.customize(RekeyTransitionItemViewTheme())

        addSubview(rekeyOldTransitionView)
        rekeyOldTransitionView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.lessThanOrEqualTo(titleLabel.snp.bottom).offset(theme.rekeyOldTransitionViewTopPadding)
        }
    }

    private func addLoadingImage(_ theme: RekeyConfirmationViewTheme) {
        loadingImage.setAnimation(theme.lottie)

        addSubview(loadingImage)
        loadingImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(rekeyOldTransitionView.snp.bottom).offset(theme.loadingImageVerticalPadding)
        }
    }
    
    private func addRekeyNewTransitionView(_ theme: RekeyConfirmationViewTheme) {
        rekeyNewTransitionView.customize(RekeyTransitionItemViewTheme())

        addSubview(rekeyNewTransitionView)
        rekeyNewTransitionView.snp.makeConstraints {
            $0.centerX.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(loadingImage.snp.bottom).offset(theme.loadingImageVerticalPadding)
        }
    }

    private func addFinalizeButton(_ theme: RekeyConfirmationViewTheme) {
        finalizeButton.customize(theme.finalizeButtonTheme)
        finalizeButton.bindData(ButtonCommonViewModel(title: "ledger-rekey-finalize".localized))

        addSubview(finalizeButton)
        finalizeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.greaterThanOrEqualTo(rekeyNewTransitionView.snp.bottom).offset(theme.bottomPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }
    }

    private func addFeeLabel(_ theme: RekeyConfirmationViewTheme) {
        feeLabel.customizeAppearance(theme.feeTitle)

        addSubview(feeLabel)
        feeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.feeTitlePaddings.leading)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalTo(finalizeButton.snp.top).offset(-theme.feeTitlePaddings.bottom)
        }
    }

    private func addInfoImage(_ theme: RekeyConfirmationViewTheme) {
        infoImage.customizeAppearance(theme.infoImage)

        addSubview(infoImage)
        infoImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.horizontalPadding)
            $0.centerY.equalTo(feeLabel)
        }
    }
}

extension RekeyConfirmationView {
    func bindData(_ viewModel: RekeyConfirmationViewModel) {
        rekeyOldTransitionView.bindData(
            image: viewModel.oldImage,
            title: viewModel.oldTransitionTitle,
            value: viewModel.oldTransitionValue
        )
        rekeyNewTransitionView.bindData(
            image: viewModel.newLedgerImage,
            title: viewModel.newTransitionTitle,
            value: viewModel.newTransitionValue
        )

        feeLabel.text = viewModel.feeValue
    }
}

extension RekeyConfirmationView {
    func startAnimatingImageView() {
        loadingImage.play(with: LottieImageView.Configuration())
    }

    func stopAnimatingImageView() {
        loadingImage.stop()
    }
}

protocol RekeyConfirmationViewDelegate: AnyObject {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView)
}
