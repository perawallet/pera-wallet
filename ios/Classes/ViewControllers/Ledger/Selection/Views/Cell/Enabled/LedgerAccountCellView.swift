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
//  LedgerAccountCellView.swift

import MacaroonUIKit
import UIKit

final class LedgerAccountCellView: View, TripleShadowDrawable {
    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()

    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()

    weak var delegate: LedgerAccountViewDelegate?

    private lazy var theme = LedgerAccountCellViewTheme()
    private lazy var checkboxImageView = UIImageView()
    private lazy var verticalStackView = UIStackView()
    private lazy var deviceNameLabel = UILabel()
    private lazy var assetInfoLabel = UILabel()
    private lazy var infoButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        setListeners()
    }

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

    func customize(_ theme: LedgerAccountCellViewTheme) {
        drawAppearance(corner: theme.corner)
        drawAppearance(shadow: theme.firstShadow)
        drawAppearance(secondShadow: theme.secondShadow)
        drawAppearance(thirdShadow: theme.thirdShadow)

        addCheckboxImageView(theme)
        addInfo(theme)
        addVerticalStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        infoButton.addTarget(self, action: #selector(notifyDelegateToOpenMoreInfo), for: .touchUpInside)
    }
}

extension LedgerAccountCellView {
    private func addCheckboxImageView(_ theme: LedgerAccountCellViewTheme) {
        checkboxImageView.customizeAppearance(theme.unselectedStateCheckbox)

        addSubview(checkboxImageView)
        checkboxImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.checkboxIconSize)
        }
    }

    private func addInfo(_ theme: LedgerAccountCellViewTheme) {
        infoButton.customizeAppearance(theme.infoButtonStyle)

        addSubview(infoButton)
        infoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.infoIconSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addVerticalStackView(_ theme: LedgerAccountCellViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillProportionally

        verticalStackView.snp.makeConstraints {
            $0.leading.equalTo(checkboxImageView.snp.trailing).offset(theme.nameHorizontalOffset)
            $0.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(-theme.nameHorizontalOffset)
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
        }

        addDeviceNameLabel(theme)
        addAssetInfoLabel(theme)
    }

    private func addDeviceNameLabel(_ theme: LedgerAccountCellViewTheme) {
        deviceNameLabel.customizeAppearance(theme.nameLabel)

        verticalStackView.addArrangedSubview(deviceNameLabel)
    }

    private func addAssetInfoLabel(_ theme: LedgerAccountCellViewTheme) {
        assetInfoLabel.customizeAppearance(theme.assetInfoLabel)

        assetInfoLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        verticalStackView.addArrangedSubview(assetInfoLabel)
    }
}

extension LedgerAccountCellView {
    @objc
    private func notifyDelegateToOpenMoreInfo() {
        delegate?.ledgerAccountViewDidOpenMoreInfo(self)
    }
}

extension LedgerAccountCellView: ViewModelBindable {
    func bindData(_ viewModel: LedgerAccountViewModel?) {
        deviceNameLabel.text = viewModel?.accountNameViewModel?.name

        if let assetCount = viewModel?.accountAssetCountViewModel?.assetCount {
            assetInfoLabel.text = assetCount
        } else {
            assetInfoLabel.isHidden = true
        }
    }
}

extension LedgerAccountCellView {
    func didSelectCell(_ selected: Bool) {
        if selected {
            draw(border: theme.selectedStateBorder)
            checkboxImageView.customizeAppearance(theme.selectedStateCheckbox)
        } else {
            eraseBorder()
            checkboxImageView.customizeAppearance(theme.unselectedStateCheckbox)
        }
    }
}

protocol LedgerAccountViewDelegate: AnyObject {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountCellView)
}
