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
//   WCSessionItemView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCSessionItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var contentView = UIView()
    private lazy var imageView = URLImageView()
    private lazy var nameView = UILabel()
    private lazy var wcV1BadgeView = Label()
    private lazy var descriptionView = UILabel()
    private lazy var statusView = Label()
    private lazy var disclosureIconView = UIImageView()

    private var theme: WCSessionItemViewTheme?

    func customize(_ theme: WCSessionItemViewTheme) {
        self.theme = theme

        addContent(theme)
        addDisclosureIcon(theme)
    }

    func bindData(_ viewModel: WCSessionItemViewModel?) {
        imageView.load(from: viewModel?.image)

        if let name = viewModel?.name {
            name.load(in: nameView)
        } else {
            nameView.clearText()
        }

        if let wcV1Badge = viewModel?.wcV1Badge {
            wcV1Badge.load(in: wcV1BadgeView)
        } else {
            wcV1BadgeView.clearText()
        }

        if let description = viewModel?.description {
            description.load(in: descriptionView)
        } else {
            descriptionView.clearText()
        }
    }

    func prepareForReuse() {
        imageView.prepareForReuse()
        nameView.editText = nil
        wcV1BadgeView.editText = nil
        descriptionView.editText = nil
        statusView.resetAppearance()
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionItemViewModel?,
        for theme: WCSessionItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width

        let titleHeight: CGFloat

        let nameSize = viewModel.name?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        if let wcWCv1Badge = viewModel.wcV1Badge {
            let wcV1BadgeTitleSize = wcWCv1Badge.boundingSize(
                multiline: false,
                fittingSize: CGSize((width, .greatestFiniteMagnitude))
            )
            let wcV1BadgeSize =
                theme.wcV1BadgeContentEdgeInsets.top +
                wcV1BadgeTitleSize.height +
                theme.wcV1BadgeContentEdgeInsets.bottom

            titleHeight = max(nameSize.height, wcV1BadgeSize)
        } else {
            titleHeight = nameSize.height
        }

        let descriptionFittingWidth =
            width -
            theme.imageSize.w -
            2 * theme.nameHorizontalPadding -
            (theme.disclosureIcon.image?.uiImage.size.width ?? .zero)
        let descriptionSize = viewModel.description?.boundingSize(
            multiline: true,
            fittingSize: CGSize((descriptionFittingWidth, .greatestFiniteMagnitude))
        ).height ?? .zero
        let statusSize = theme.pingingStatus.text?.text.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        let preferredHeight =
            titleHeight +
            theme.descriptionTopPadding +
            descriptionSize +
            theme.spacingBetweeenDescriptionAndStatus +
            theme.statusContentEdgeInsets.top +
            statusSize.height +
            theme.statusContentEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance( _ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        updateUIWhenUserInterfaceStyleDidChange()
    }
}

extension WCSessionItemView {
    private func updateUIWhenUserInterfaceStyleDidChange() {
        if let theme {
            imageView.draw(border: theme.imageBorder)
        }
    }
}

extension WCSessionItemView {
    func updateStatus(_ status: WCSessionStatus) {
        guard let theme else { return }

        let style = theme[status]
        statusView.customizeAppearance(style)
    }
}

extension WCSessionItemView {
    private func addContent(_ theme: WCSessionItemViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }

        addImage(theme)
        addName(theme)
        addWCv1Badge(theme)
        addDescription(theme)
        addStatus(theme)
    }

    private func addImage(_ theme: WCSessionItemViewTheme) {
        imageView.build(theme.image)
        imageView.draw(border: theme.imageBorder)
        imageView.draw(corner: theme.imageCorner)

        contentView.addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addName(_ theme: WCSessionItemViewTheme) {
        nameView.customizeAppearance(theme.name)

        contentView.addSubview(nameView)
        nameView.snp.makeConstraints {
            $0.top == 0
            $0.leading == imageView.snp.trailing + theme.nameHorizontalPadding
        }
    }

    private func addWCv1Badge(_ theme: WCSessionItemViewTheme) {
        wcV1BadgeView.customizeAppearance(theme.wcV1Badge)
        wcV1BadgeView.draw(corner: theme.wcV1BadgeCorner)
        wcV1BadgeView.contentEdgeInsets = theme.wcV1BadgeContentEdgeInsets

        contentView.addSubview(wcV1BadgeView)
        wcV1BadgeView.fitToHorizontalIntrinsicSize()
        wcV1BadgeView.snp.makeConstraints {
            $0.height >= nameView
            $0.centerY == nameView
            $0.leading == nameView.snp.trailing + theme.spacingBetweenWCv1BadgeAndName
            $0.trailing <= 0
        }
    }

    private func addDescription(_ theme: WCSessionItemViewTheme) {
        descriptionView.customizeAppearance(theme.description)

        contentView.addSubview(descriptionView)
        descriptionView.fitToVerticalIntrinsicSize()
        descriptionView.snp.makeConstraints {
            $0.top == wcV1BadgeView.snp.bottom + theme.descriptionTopPadding
            $0.leading == nameView
            $0.trailing == 0
        }
    }

    private func addStatus(_ theme: WCSessionItemViewTheme) {
        statusView.draw(corner: theme.statusCorner)
        statusView.contentEdgeInsets = theme.statusContentEdgeInsets

        contentView.addSubview(statusView)
        statusView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.spacingBetweeenDescriptionAndStatus
            $0.leading == nameView
            $0.bottom == 0
            $0.trailing <= 0
        }
    }

    private func addDisclosureIcon(_ theme: WCSessionItemViewTheme) {
        disclosureIconView.customizeAppearance(theme.disclosureIcon)

        addSubview(disclosureIconView)
        disclosureIconView.fitToIntrinsicSize()
        disclosureIconView.snp.makeConstraints {
            $0.top == theme.disclosureIconTopPadding
            $0.leading == contentView.snp.trailing + theme.spacingBetweenContentAndDisclosureIcon
            $0.trailing == 0
        }
    }
}
