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

//   WCSessionConnectionScreenTheme.swift

import UIKit
import MacaroonUIKit

struct WCSessionConnectionScreenTheme:
    LayoutSheet,
    StyleSheet {
    let background: ViewStyle
    let spacingBetweenListAndPrimaryAction: LayoutMetric
    let primaryAction: ButtonStyle
    let secondaryAction: ButtonStyle
    let secondaryActionWidthMultiplier: LayoutMetric
    let actionEdgeInsets: LayoutPaddings
    let actionMargins: LayoutMargins
    let spacingBetweenActions: LayoutMetric
    let defaultBottomSheetHeightProportionForLoading: LayoutMetric

    init(_ family: LayoutFamily) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.spacingBetweenListAndPrimaryAction = 24
        self.primaryAction = [
            .title("title-connect".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Primary.text),
                .disabled(Colors.Button.Primary.disabledText)
            ]),
            .backgroundImage([
                .normal("components/buttons/primary/bg"),
                .highlighted("components/buttons/primary/bg-highlighted"),
                .disabled("components/buttons/primary/bg-disabled")
            ])
        ]
        self.secondaryAction = [
            .title("title-cancel".localized),
            .font(Typography.bodyMedium()),
            .titleColor([
                .normal(Colors.Button.Secondary.text)
            ]),
            .backgroundImage([
                .normal("components/buttons/secondary/bg"),
                .highlighted("components/buttons/secondary/bg-highlighted")
            ])
        ]
        self.secondaryActionWidthMultiplier = 1.5
        self.actionEdgeInsets = (16, 8, 16, 8)
        self.actionMargins = (.noMetric, 24, 12, 24)
        self.spacingBetweenActions = 20
        self.defaultBottomSheetHeightProportionForLoading = 0.45
    }
}

extension WCSessionConnectionScreenTheme{
    func calculateModalHeightAsBottomSheet(
        _ screen: WCSessionConnectionScreen
    ) -> ModalHeight {
        let isEmpty = screen.dataSource.snapshot(for: .accounts).items.isEmpty
        return
            isEmpty
            ? .proportional(defaultBottomSheetHeightProportionForLoading)
            : .preferred(
                calculateHeightAsBottomSheet(
                    screen
                )
            )
    }

    private func calculateHeightAsBottomSheet(
        _ screen: WCSessionConnectionScreen
    ) -> LayoutMetric {
        let listItemsHeight = calculateTotalListItemHeight(screen)
        let listSectionsHeight = calculateTotalListSectionHeight(screen)
        let listContentVerticalInset = screen.listView.contentInset.vertical

        let totalHeight =
            listItemsHeight +
            listSectionsHeight +
            listContentVerticalInset +
            screen.additionalSafeAreaInsets.bottom
        return totalHeight
    }

    private func calculateTotalListItemHeight(
        _ screen: WCSessionConnectionScreen
    ) -> CGFloat {
        let itemIdentifiers = screen.dataSource.snapshot().itemIdentifiers
        let height = itemIdentifiers.reduce(CGFloat.zero) { total, itemIdentifier in
            guard
                let indexPath = screen.dataSource.indexPath(for: itemIdentifier)
            else {
                return total
            }
            let itemHeight = screen.listLayout.collectionView(
                screen.listView,
                layout: screen.listView.collectionViewLayout,
                sizeForItemAt: indexPath
            ).height
            return total + itemHeight
        }
        return height.ceil()
    }

    private func calculateTotalListSectionHeight(
        _ screen: WCSessionConnectionScreen
    ) -> CGFloat {
        let sectionIdentifiers = screen.dataSource.snapshot().sectionIdentifiers
        let height = sectionIdentifiers.reduce(CGFloat.zero) { total, sectionIdentifier in
            guard
                let indexOfSection = screen.dataSource.snapshot().indexOfSection(sectionIdentifier)
            else {
                return total
            }

            let sectionInsets = screen.listLayout.collectionView(
                screen.listView,
                layout: screen.listView.collectionViewLayout,
                insetForSectionAt: indexOfSection
            ).vertical
            let sectionHeaderHeight = screen.listLayout.collectionView(
                screen.listView,
                layout: screen.listView.collectionViewLayout,
                referenceSizeForHeaderInSection: indexOfSection
            ).height

            return total + sectionInsets + sectionHeaderHeight
        }
        return height.ceil()
    }
}
