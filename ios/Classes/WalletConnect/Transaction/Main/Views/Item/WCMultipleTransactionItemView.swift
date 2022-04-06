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
//   WCMultipleTransactionItemView.swift

import UIKit
import MacaroonUIKit

class WCMultipleTransactionItemView: TripleShadowView {

    private let layout = Layout<LayoutConstants>()

    private lazy var titleStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 8.0
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return stackView
    }()

    private lazy var warningImageView = UIImageView(image: img("icon-red-warning"))

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Text.main.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.regular.make(19).uiFont)
            .withText("wallet-connect-transaction-title-multiple".localized)
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Text.grayLighter.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.regular.make(13).uiFont)
    }()

    private lazy var showDetailLabel: UILabel = {
        UILabel()
            .withTextColor(AppColors.Components.Link.primary.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.bold.make(13).uiFont)
            .withText("title-show-transaction-detail".localized)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
        prepareLayout()
    }

    func configureAppearance() {
        backgroundColor = AppColors.Shared.System.background.uiColor
        layer.cornerRadius = 12.0

        let accountContainerCorner = Corner(radius: 4)
        let accountContainerBorder = Border(color: AppColors.SendTransaction.Shadow.first.uiColor, width: 1)

        let accountContainerFirstShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.first.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        let accountContainerSecondShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.second.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        let accountContainerThirdShadow = MacaroonUIKit.Shadow(
            color: AppColors.SendTransaction.Shadow.third.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            fillColor: AppColors.Shared.System.background.uiColor,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        draw(corner: accountContainerCorner)
        drawAppearance(border: accountContainerBorder)

        drawAppearance(shadow: accountContainerFirstShadow)
        drawAppearance(secondShadow: accountContainerSecondShadow)
        drawAppearance(thirdShadow: accountContainerThirdShadow)
    }

    func prepareLayout() {
        setupTitleStackViewLayout()
        setupDetailLabelLayout()
        setupShowDetailLabelLayout()
    }
}

extension WCMultipleTransactionItemView {
    private func setupTitleStackViewLayout() {
        addSubview(titleStackView)

        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }

        titleStackView.addArrangedSubview(warningImageView)
        titleStackView.addArrangedSubview(titleLabel)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleStackView.addArrangedSubview(spacer)
    }

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(titleStackView.snp.bottom).offset(layout.current.minimumOffset)
        }
    }

    private func setupShowDetailLabelLayout() {
        addSubview(showDetailLabel)

        showDetailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
}

extension WCMultipleTransactionItemView {
    func bind(_ viewModel: WCMultipleTransactionItemViewModel) {
        warningImageView.isHidden = !viewModel.hasWarning
        detailLabel.text = viewModel.detail
    }
}

extension WCMultipleTransactionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 24.0
        let stackTrailingOffset: CGFloat = 44.0
        let minimumOffset: CGFloat = 4.0
        let detailTopInset: CGFloat = 8.0
    }
}
