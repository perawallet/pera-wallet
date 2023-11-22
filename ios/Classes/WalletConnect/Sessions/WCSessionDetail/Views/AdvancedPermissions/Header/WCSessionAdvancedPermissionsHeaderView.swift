// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WCSessionAdvancedPermissionsHeaderView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSessionAdvancedPermissionsHeaderView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable,
    UIContentView {
    var configuration: UIContentConfiguration

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performInfoAction: TargetActionInteraction()
    ]
    
    private lazy var titleView = UILabel()
    private lazy var infoActionView = MacaroonUIKit.Button()

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)
    }

    func customize(_ theme: WCSessionAdvancedPermissionsHeaderViewTheme) {
        addTitle(theme)
        addInfoAction(theme)
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionAdvancedPermissionsHeaderViewModel?,
        for theme: WCSessionAdvancedPermissionsHeaderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let maxContextSize = CGSize((width, .greatestFiniteMagnitude))
        let titleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: maxContextSize
        ) ?? .zero
        let iconSize = theme.infoAction.icon?[.normal]?.size ?? .zero
        let minHeight: CGFloat = 30 /// <note> For increasing the tap area for expanding the header.
        let preferredHeight = [
            titleSize.height,
            iconSize.height,
            minHeight
        ].max()!
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) { }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) { }

    func bindData(_ viewModel: WCSessionAdvancedPermissionsHeaderViewModel?) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.clearText()
        }
    }
}

extension WCSessionAdvancedPermissionsHeaderView {
    private func addTitle(_ theme: WCSessionAdvancedPermissionsHeaderViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            let iconHeight = theme.infoAction.icon?[.normal]?.height ?? .zero
            $0.greaterThanHeight(iconHeight)

            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addInfoAction(_ theme: WCSessionAdvancedPermissionsHeaderViewTheme) {
        infoActionView.customizeAppearance(theme.infoAction)

        infoActionView.contentEdgeInsets.left = theme.spacingBetweenTitleAndInfoAction
        addSubview(infoActionView)
        infoActionView.fitToHorizontalIntrinsicSize()
        infoActionView.snp.makeConstraints {
            $0.top == 0
            $0.leading == titleView.snp.trailing
            $0.bottom == 0
            $0.trailing <= theme.spacingBetweenTitleAndInfoAction
        }

        startPublishing(
            event: .performInfoAction,
            for: infoActionView
        )
    }
}

extension WCSessionAdvancedPermissionsHeaderView {
    enum Event {
        case performInfoAction
    }
}
