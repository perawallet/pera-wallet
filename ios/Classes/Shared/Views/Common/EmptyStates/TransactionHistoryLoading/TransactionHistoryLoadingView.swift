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
//   TransactionHistoryLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class TransactionHistoryLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var titleView = ShimmerView()
    private lazy var sectionView = ShimmerView()
    private lazy var firstRow = TransactionHistoryLoadingItemView()
    private lazy var secondRow = TransactionHistoryLoadingItemView()
    private lazy var secondSectionView = ShimmerView()
    private lazy var thirdRow = TransactionHistoryLoadingItemView()
    private lazy var fourthRow = TransactionHistoryLoadingItemView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: TransactionHistoryLoadingViewTheme
    ) {
        addTitleView(theme)
        addFirstSection(theme)
        addSecondSection(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }
}

extension TransactionHistoryLoadingView {
    private func addTitleView(_ theme: TransactionHistoryLoadingViewTheme) {
        titleView.draw(corner: Corner(radius: theme.titleViewCorner))

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.titleViewSize.w,
                       height: theme.titleViewSize.h)
            )
        }
    }

    private func addFirstSection(_ theme: TransactionHistoryLoadingViewTheme) {
        sectionView.draw(corner: Corner(radius: theme.sectionCorner))

        addSubview(sectionView)
        sectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(titleView.snp.bottom).offset(theme.sectionMargin.top)
            $0.size.equalTo(
                CGSize(width: theme.sectionSize.w,
                       height: theme.sectionSize.h)
            )
        }

        firstRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(firstRow)
        firstRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(sectionView.snp.bottom).offset(theme.itemMargin.top)
            $0.height.equalTo(theme.itemSize.h)
        }

        secondRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(secondRow)
        secondRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(firstRow.snp.bottom)
            $0.height.equalTo(theme.itemSize.h)
        }
    }

    private func addSecondSection(_ theme: TransactionHistoryLoadingViewTheme) {
        secondSectionView.draw(corner: Corner(radius: theme.sectionCorner))

        addSubview(secondSectionView)
        secondSectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(secondRow.snp.bottom).offset(theme.sectionMargin.top)
            $0.size.equalTo(
                CGSize(width: theme.sectionSize.w,
                       height: theme.sectionSize.h)
            )
        }

        thirdRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(thirdRow)
        thirdRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(secondSectionView.snp.bottom).offset(theme.itemMargin.top)
            $0.height.equalTo(theme.itemSize.h)
        }

        fourthRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(fourthRow)
        fourthRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(thirdRow.snp.bottom)
            $0.height.equalTo(theme.itemSize.h)
        }
    }
}
