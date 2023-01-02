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

//   DiscoverNavigationBarView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class DiscoverNavigationBarView:
    BaseView,
    MacaroonUIKit.NavigationBarLargeTitleView {
    var title: EditText? {
        get { titleView.editText }
        set { titleView.editText = newValue }
    }

    var scrollEdgeOffset: CGFloat {
        return bounds.height - titleView.frame.maxY
    }

    var searchAction: EmptyHandler?

    private lazy var titleView = UILabel()
    private lazy var searchButton = MacaroonUIKit.Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme: DiscoverNavigationBarViewTheme())
    }

    private func customize(theme: DiscoverNavigationBarViewTheme) {
        addTitle(theme)
        addSearchButton(theme)
    }
}

extension DiscoverNavigationBarView {
    private func addTitle(_ theme: DiscoverNavigationBarViewTheme) {
        addSubview(titleView)
        titleView.customizeAppearance([.textOverflow(FittingText())])
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.setPaddings(theme.titleInset)
        }
    }

    private func addSearchButton(_ theme: DiscoverNavigationBarViewTheme) {
        searchButton.customizeAppearance([.icon([.normal("icon-navigation-search")])])
        addSubview(searchButton)
        searchButton.fitToVerticalIntrinsicSize()
        searchButton.snp.makeConstraints {
            $0.top == 0
            $0.trailing == 0
            $0.height.equalTo(theme.searchButtonSize.h)
            $0.width.equalTo(theme.searchButtonSize.w)
        }

        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
    }

    @objc
    private func didTapSearch() {
        searchAction?()
    }
}
