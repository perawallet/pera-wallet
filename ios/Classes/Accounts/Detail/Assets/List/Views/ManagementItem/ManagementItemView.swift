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

//   AssetManagementItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ManagementItemView:
    View,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .primaryAction: TargetActionInteraction(),
        .secondaryAction: TargetActionInteraction()
    ]
    
    private lazy var titleView = Label()
    private lazy var primaryButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    private lazy var secondaryButton = MacaroonUIKit.Button()
    
    func customize(_ theme: ManagementItemViewTheme) {
        addSecondaryButton(theme)
        addPrimaryButton(theme)
        addTitle(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension ManagementItemView {
    private func addTitle(_ theme: ManagementItemViewTheme) {
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(primaryButton.snp.leading).offset(-theme.spacing)
        }
    }
    
    private func addPrimaryButton(_ theme: ManagementItemViewTheme) {
        primaryButton.customizeAppearance(theme.primaryButton)

        addSubview(primaryButton)
        primaryButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(secondaryButton.snp.leading).offset(-theme.spacing)
        }
        
        startPublishing(
            event: .primaryAction,
            for: primaryButton
        )
    }
    
    private func addSecondaryButton(_ theme: ManagementItemViewTheme) {
        secondaryButton.customizeAppearance(theme.secondaryButton)

        addSubview(secondaryButton)
        secondaryButton.fitToIntrinsicSize()
        secondaryButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
        }
        
        startPublishing(
            event: .secondaryAction,
            for: secondaryButton
        )
    }
}

extension ManagementItemView: ViewModelBindable {
    func bindData(_ viewModel: ManagementItemViewModel?) {
        titleView.editText = viewModel?.title
        primaryButton.setEditTitle(
            viewModel?.primaryButtonTitle,
            for: .normal
        )
        primaryButton.setImage(
            viewModel?.primaryButtonIcon?.uiImage,
            for: .normal
        )
        secondaryButton.setEditTitle(
            viewModel?.secondaryButtonTitle,
            for: .normal
        )
        secondaryButton.setImage(
            viewModel?.secondaryButtonIcon?.uiImage,
            for: .normal
        )
    }

    class func calculatePreferredSize(
        _ viewModel: ManagementItemViewModel?,
        for layoutSheet: ManagementItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight = max(layoutSheet.buttonHeight, titleSize.height)

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension ManagementItemView {
    enum Event {
        case primaryAction
        case secondaryAction
    }
}
