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

final class AssetManagementItemView:
    View,
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .manage: UIControlInteraction(),
        .add: UIControlInteraction()
    ]
    
    private lazy var titleView = Label()
    private lazy var manageButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    private lazy var addButton = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    
    func customize(_ theme: AssetManagementItemViewTheme) {
        addAddButton(theme)
        addManageButton(theme)
        addTitle(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AssetManagementItemView {
    private func addTitle(_ theme: AssetManagementItemViewTheme) {
        titleView.editText = theme.title
        
        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(manageButton.snp.leading).offset(-theme.spacing)
        }
    }
    
    private func addManageButton(_ theme: AssetManagementItemViewTheme) {
        manageButton.customizeAppearance(theme.manageButton)
        
        addSubview(manageButton)
        manageButton.fitToIntrinsicSize()
        manageButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(addButton.snp.leading).offset(-theme.spacing)
        }
        
        startPublishing(
            event: .manage,
            for: manageButton
        )
    }
    
    private func addAddButton(_ theme: AssetManagementItemViewTheme) {
        addButton.customizeAppearance(theme.addButton)
        
        addSubview(addButton)
        addButton.fitToIntrinsicSize()
        addButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
        }
        
        startPublishing(
            event: .add,
            for: addButton
        )
    }
}

extension AssetManagementItemView {
    enum Event {
        case manage
        case add
    }
}
