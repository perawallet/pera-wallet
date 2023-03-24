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

//   MoonPayTransactionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class MoonPayTransactionView:
    View,
    ViewModelBindable,
    UIInteractable {

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .close: TargetActionInteraction()
    ]

    private lazy var imageView = ImageView()
    private lazy var titleView = Label()
    private lazy var descriptionView = Label()
    private lazy var accountStackView = HStackView()
    private lazy var accountTitleView = Label()
    private lazy var accountAddressView = UIView()
    private lazy var accountIconView = ImageView()
    private lazy var accountAddressTitleView = Label()
    private lazy var doneButton = MacaroonUIKit.Button()
    
    func customize(_ theme: MoonPayTransactionViewTheme) {
        addImageView(theme)
        addTitleView(theme)
        addDescriptionView(theme)
        addAccountView(theme)
        addDoneButton(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func bindData(_ viewModel: MoonPayTransactionViewModel?) {
        imageView.image = viewModel?.image?.uiImage
        titleView.editText = viewModel?.title
        descriptionView.editText = viewModel?.description
        accountIconView.image = viewModel?.accountIcon?.uiImage
        accountAddressTitleView.editText = viewModel?.accountName
    }
}

extension MoonPayTransactionView {
    private func addImageView(_ theme: MoonPayTransactionViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToSize(theme.imageViewSize)
        }
    }
    
    private func addTitleView(_ theme: MoonPayTransactionViewTheme) {
        titleView.customizeAppearance(theme.titleLabel)
        
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addDescriptionView(_ theme: MoonPayTransactionViewTheme) {
        descriptionView.customizeAppearance(theme.descriptionLabel)
        addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.descriptionTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
        descriptionView.addSeparator(theme.separator, padding: -theme.descriptionSeparatorTopPadding)
    }
    
    private func addAccountView(_ theme: MoonPayTransactionViewTheme) {
        accountStackView.distribution = .equalSpacing
        addSubview(accountStackView)
        accountStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(descriptionView.snp.bottom).offset(theme.accountTopPadding)
        }
        addAccountTitle(theme)
        addAccountAddress(theme)
    }
    
    private func addAccountTitle(_ theme: MoonPayTransactionViewTheme) {
        accountTitleView.customizeAppearance(theme.accountLabel)
        accountStackView.addArrangedSubview(accountTitleView)
    }

    private func addAccountAddress(_ theme: MoonPayTransactionViewTheme) {
        accountStackView.addArrangedSubview(accountAddressView)
        
        accountAddressView.addSubview(accountIconView)
        accountIconView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.fitToSize((24, 24))
        }
        
        accountAddressTitleView.customizeAppearance(theme.addressLabel)
        accountAddressView.addSubview(accountAddressTitleView)
        accountAddressTitleView.snp.makeConstraints {
            $0.leading.equalTo(accountIconView.snp.trailing).offset(8)
            $0.trailing.top.bottom.equalToSuperview()
        }
    }
     
    private func addDoneButton(_ theme: MoonPayTransactionViewTheme) {
        doneButton.contentEdgeInsets = UIEdgeInsets(theme.buttonContentEdgeInsets)
        doneButton.draw(corner: theme.buttonCorner)
        doneButton.customizeAppearance(theme.doneButton)
        
        addSubview(doneButton)
        doneButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(accountStackView.snp.bottom).offset(theme.doneButtonTopPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.doneButtonBottomPadding)
        }

        startPublishing(
            event: .close,
            for: doneButton
        )
    }
}

extension MoonPayTransactionView {
    enum Event {
        case close
    }
}
