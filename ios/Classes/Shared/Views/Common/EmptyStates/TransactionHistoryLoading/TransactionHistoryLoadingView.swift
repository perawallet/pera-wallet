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
    private lazy var filterView = TransactionHistoryFilterView()
    private lazy var sectionLeadingLineView = UIView()
    private lazy var sectionView = ShimmerView()
    private lazy var sectionTrailingLineView = UIView()
    private lazy var firstRow = TransactionHistoryLoadingItemView()
    private lazy var secondRow = TransactionHistoryLoadingItemView()
    private lazy var thirdRow = TransactionHistoryLoadingItemView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: TransactionHistoryLoadingViewTheme
    ) {
        addFilterView(theme)
        addFirstSection(theme)
        addSectionLines(theme)
        addFirstRow(theme)
        addSecondRow(theme)
        addThirdRow(theme)
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

    private func addFilterView(_ theme: TransactionHistoryLoadingViewTheme) {
        filterView.customize(TransactionHistoryHeaderViewTheme())
        filterView.bindData(TransactionHistoryFilterViewModel(.allTime))

        addSubview(filterView)
        filterView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(theme.filterViewMargin.leading)
            $0.trailing.equalToSuperview().inset(theme.filterViewMargin.trailing)
            $0.height.equalTo(theme.filterViewHeight)
        }
    }

    private func addFirstSection(_ theme: TransactionHistoryLoadingViewTheme) {
        sectionView.draw(corner: Corner(radius: theme.sectionCorner))

        addSubview(sectionView)
        sectionView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(filterView.snp.bottom).offset(theme.sectionMargin.top)
            $0.size.equalTo(
                CGSize(width: theme.sectionSize.w,
                       height: theme.sectionSize.h)
            )
        }
    }

    private func addSectionLines(_ theme: TransactionHistoryLoadingViewTheme) {
        sectionLeadingLineView.customizeAppearance(theme.sectionLineStyle)

        addSubview(sectionLeadingLineView)
        sectionLeadingLineView.snp.makeConstraints {
            $0.centerY.equalTo(sectionView)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(sectionView.snp.leading).offset(-theme.sectionLinePaddings.leading)
            $0.height.equalTo(theme.sectionLineHeight)
        }

        sectionTrailingLineView.customizeAppearance(theme.sectionLineStyle)

        addSubview(sectionTrailingLineView)
        sectionTrailingLineView.snp.makeConstraints {
            $0.centerY.equalTo(sectionView)
            $0.trailing.equalToSuperview()
            $0.leading.equalTo(sectionView.snp.trailing).offset(theme.sectionLinePaddings.trailing)
            $0.height.equalTo(theme.sectionLineHeight)
        }
    }

    private func addFirstRow(_ theme: TransactionHistoryLoadingViewTheme) {
        firstRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(firstRow)
        firstRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(sectionView.snp.bottom).offset(theme.itemMargin.top)
            $0.height.equalTo(theme.itemSize.h)
        }

        firstRow.addSeparator(theme.itemSeparator)
    }

    private func addSecondRow(_ theme: TransactionHistoryLoadingViewTheme) {
        secondRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(secondRow)
        secondRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(firstRow.snp.bottom)
            $0.height.equalTo(theme.itemSize.h)
        }

        secondRow.addSeparator(theme.itemSeparator)
    }

    private func addThirdRow(_ theme: TransactionHistoryLoadingViewTheme) {
        thirdRow.customize(TransactionHistoryLoadingItemViewCommonTheme())

        addSubview(thirdRow)
        thirdRow.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(secondRow.snp.bottom)
            $0.height.equalTo(theme.itemSize.h)
        }
    }
}
