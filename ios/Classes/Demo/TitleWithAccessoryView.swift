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
//   TitleWithAccessoryView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class TitleWithAccessoryView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performAccessory: TargetActionInteraction()
    ]
    
    /// TODO: Used UILabel instead Label because it causes that text shrinks when you change tab and go back multiple times
    /// Possible issue is text rect is changing with incorrect value
    private lazy var titleView = UILabel()
    private lazy var accessoryView = MacaroonUIKit.Button()
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: TitleWithAccessoryViewTheme
    ) {
        addTitle(theme)
        addAccessory(theme)
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}
    
    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
    
    func bindData(
        _ viewModel: TitleWithAccessoryViewModel?
    ) {
        titleView.editText = viewModel?.title
        
        if let accessory = viewModel?.accessory {
            accessoryView.customizeAppearance(accessory)
        } else {
            accessoryView.resetAppearance()
        }
        
        accessoryView.contentEdgeInsets = viewModel?.accessoryContentEdgeInsets ?? .zero
    }
    
    class func calculatePreferredSize(
        _ viewModel: TitleWithAccessoryViewModel?,
        for theme: TitleWithAccessoryViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        /// <warning>
        /// The constrained widths of the accessory view will be discarded from the calculations
        /// because the title will not has the multi-line texts as of now.
        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let preferredHeight =
            theme.titleVerticalPaddings.top +
            titleSize.height +
            theme.titleVerticalPaddings.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension TitleWithAccessoryView {
    private func addTitle(
        _ theme: TitleWithAccessoryViewTheme
    ) {
        titleView.customizeAppearance(theme.title)
        
        addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.titleVerticalPaddings.top
            $0.leading == 0
            $0.bottom == theme.titleVerticalPaddings.bottom
        }
    }
    
    private func addAccessory(
        _ theme: TitleWithAccessoryViewTheme
    ) {
        addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading >= titleView.snp.trailing
            $0.trailing == 0
        }

        startPublishing(
            event: .performAccessory,
            for: accessoryView
        )
    }
}

extension TitleWithAccessoryView {
    enum Event {
        case performAccessory
    }
}
