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
//   WCAssetConfigTransactionItemView.swift

import UIKit
import MacaroonUIKit

class WCAssetConfigTransactionItemView: TripleShadowView {

    private let layout = Layout<LayoutConstants>()

    private lazy var showDetailLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Link.primary.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.bold.make(13).uiFont)
            .withText("title-show-transaction-detail".localized)
    }()

    private lazy var warningImageView = UIImageView(image: img("icon-orange-warning"))

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.main.uiColor)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(Fonts.DMSans.regular.make(19).uiFont)
    }()

    private(set) lazy var accountInformationView = WCGroupTransactionAccountInformationView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
        prepareLayout()
    }
    
    func configureAppearance() {
        let accountContainerFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        let accountContainerSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (4, 4),
            corners: .allCorners
        )

        let accountContainerThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        
        drawAppearance(shadow: accountContainerFirstShadow)
        drawAppearance(secondShadow: accountContainerSecondShadow)
        drawAppearance(thirdShadow: accountContainerThirdShadow)
    }

    func prepareLayout() {
        setupAccountInformationViewLayout()
        setupTitleLabelLayout()
        setupShowDetailLabelLayout()
    }

    func removeAccountInformation() {
        accountInformationView.removeFromSuperview()

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.accountInformationViewInset)
        }
    }
}

extension WCAssetConfigTransactionItemView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(accountInformationView.snp.bottom).offset(layout.current.detailTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }

    private func setupAccountInformationViewLayout() {
        addSubview(accountInformationView)

        accountInformationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.accountInformationViewInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.accountInformationViewInset)
            make.height.greaterThanOrEqualTo(layout.current.accountInformationHeight)
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

extension WCAssetConfigTransactionItemView {
    func bind(_ viewModel: WCAssetConfigTransactionItemViewModel) {
        warningImageView.isHidden = !viewModel.hasWarning

        titleLabel.text = viewModel.title

        if let accountInformationViewModel = viewModel.accountInformationViewModel {
            accountInformationView.bind(accountInformationViewModel)
        }
    }
}

extension WCAssetConfigTransactionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 24.0
        let horizontalInset: CGFloat = 20.0
        let arrowImageSize = CGSize(width: 24.0, height: 24.0)
        let stackTrailingOffset: CGFloat = 44.0
        let senderStackHeight: CGFloat = 20.0
        let detailTopInset: CGFloat = 8.0
        let accountInformationHeight: CGFloat = 36.0
        let accountInformationViewTopInset: CGFloat = 12.0
        let accountInformationViewInset: CGFloat = 8.0
    }
}
