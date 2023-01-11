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

//   WCSessionAccountStatusView.swift

import UIKit
import MacaroonUIKit

final class WCSessionAccountStatusView:
    View,
    ViewModelBindable {
    private lazy var label = Label()
    
    func customize(_ theme: WCSessionAccountStatusViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        draw(corner: theme.corner)
        
        addLabel(theme)
    }
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    static func calculatePreferredSize(
        _ viewModel: WCSessionAccountStatusViewModel?,
        for theme: WCSessionAccountStatusViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        
        let width = size.width
        
        let labelSize = viewModel.accountStatus?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        
        let preferredHeight = (theme.verticalPadding * 2) + (labelSize?.height ?? 0)
        
        return CGSize((size.width, preferredHeight))
    }
}

extension WCSessionAccountStatusView {
    private func addLabel(_ theme: WCSessionAccountStatusViewTheme) {
        label.customizeAppearance(theme.label)
        label.fitToIntrinsicSize()
        
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom == theme.verticalPadding
            $0.leading.trailing == theme.horizontalPadding
        }
    }
}

extension WCSessionAccountStatusView {
    func bindData(_ viewModel: WCSessionAccountStatusViewModel?) {
        viewModel?.accountStatus?.load(in: label)
    }
}
