// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.QRScannerOverlayViewTheme

//
//   LedgerAccountVerificationStatusView.swift

import UIKit
import MacaroonUIKit

final class LedgerAccountVerificationStatusView:
    View,
    TripleShadowDrawable {
    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()

    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()
    
    private lazy var indicatorView = ViewLoadingIndicator()
    private lazy var imageView = UIImageView()
    private lazy var verticalStackView = UIStackView()
    private lazy var statusLabel = UILabel()
    private lazy var addressLabel = UILabel()

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        drawAppearance(
            secondShadow: secondShadow
        )
        drawAppearance(
            thirdShadow: thirdShadow
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let secondShadow = secondShadow {
            updateOnLayoutSubviews(
                secondShadow: secondShadow
            )
        }

        if let thirdShadow = thirdShadow {
            updateOnLayoutSubviews(
                thirdShadow: thirdShadow
            )
        }
    }

    func customize(_ theme: LedgerAccountVerificationStatusViewTheme) {
        drawAppearance(corner: theme.corner)
        drawAppearance(shadow: theme.firstShadow)
        drawAppearance(secondShadow: theme.secondShadow)
        drawAppearance(thirdShadow: theme.thirdShadow)

        addIndicatorView(theme)
        addImageView(theme)
        addVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension LedgerAccountVerificationStatusView {
    private func addIndicatorView(_ theme: LedgerAccountVerificationStatusViewTheme) {
        indicatorView.applyStyle(theme.indicator)

        addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.imageSize)
        }
    }

    private func addImageView(_ theme: LedgerAccountVerificationStatusViewTheme) {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.imageSize)
        }
    }

    private func addVerticalStackView(_ theme: LedgerAccountVerificationStatusViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = theme.verticalStackViewSpacing

        verticalStackView.snp.makeConstraints {
            $0.leading.equalTo(indicatorView.snp.trailing).offset(theme.horizontalInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
        }

        addStatusLabel(theme)
        addAddressLabel(theme)
    }

    private func addStatusLabel(_ theme: LedgerAccountVerificationStatusViewTheme) {
        statusLabel.customizeAppearance(theme.statusLabel)

        statusLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        verticalStackView.addArrangedSubview(statusLabel)
    }

    private func addAddressLabel(_ theme: LedgerAccountVerificationStatusViewTheme) {
        addressLabel.customizeAppearance(theme.addressLabel)

        verticalStackView.addArrangedSubview(addressLabel)
    }
}

extension LedgerAccountVerificationStatusView: ViewModelBindable {
    func bindData(_ viewModel: LedgerAccountVerificationStatusViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        addressLabel.text = viewModel.address
        draw(border: Border(color: viewModel.borderColor.uiColor, width: 2))
        indicatorView.isHidden = !viewModel.isWaitingForVerification

        if viewModel.isWaitingForVerification {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }

        imageView.isHidden = viewModel.isStatusImageHidden
        imageView.image = viewModel.statusImage?.uiImage
        statusLabel.text = viewModel.statusText
        statusLabel.textColor = viewModel.statusColor.uiColor
    }
}
