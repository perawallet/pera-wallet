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
    UIInteractable,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performOptions: TargetActionInteraction()
    ]

    private lazy var imageView = URLImageView()
    private lazy var nameView = UILabel()
    private lazy var optionsActionView = MacaroonUIKit.Button()
    private lazy var descriptionView = Label()
    private lazy var dateView = UILabel()
    private lazy var statusView = Label()

    private var isLayoutFinalized = false

    func customize(
        _ theme: WCSessionItemViewTheme
    ) {
        addImage(theme)
        addName(theme)
        addOptionsAction(theme)
        addDescription(theme)
        addDate(theme)
        addStatus(theme)
    }

    func bindData(
        _ viewModel: WCSessionItemViewModel?
    ) {
        imageView.load(from: viewModel?.image)
        nameView.editText = viewModel?.name
        descriptionView.editText = viewModel?.description
        dateView.editText = viewModel?.date
        statusView.editText = viewModel?.status
    }

    func prepareForReuse() {
        imageView.prepareForReuse()
        nameView.editText = nil
        descriptionView.editText = nil
        dateView.editText = nil
        statusView.editText = nil
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

        var preferredHeight: CGFloat = .zero

        let nameSize = viewModel.name.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )

        preferredHeight += nameSize.height

        if viewModel.description != nil {
            let fittingWidth =
            width -
            theme.imageSize.w -
            2 * theme.horizontalPadding

            let descriptionSize = viewModel.description.boundingSize(
                multiline: true,
                fittingSize: CGSize((fittingWidth, .greatestFiniteMagnitude))
            )
            preferredHeight += descriptionSize.height + theme.descriptionTopPadding
        }

        let dateSize = viewModel.date.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )

        preferredHeight += dateSize.height + theme.dateTopPadding

        let statusSize = viewModel.status.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )

        preferredHeight +=
        theme.statusTopPadding +
        theme.statusContentEdgeInsets.top +
        statusSize.height +
        theme.statusContentEdgeInsets.bottom

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }

    func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    override func layoutSubviews() {
        super.layoutSubviews()

        if isLayoutFinalized ||
           statusView.bounds.isEmpty {
            return
        }

        statusView.draw(
            corner: Corner(radius: statusView.bounds.height / 2)
        )

        isLayoutFinalized = true
    }
}

extension WCSessionItemView {
    private func addImage(_ theme: WCSessionItemViewTheme) {
        imageView.build(theme.image)
        imageView.draw(border: theme.imageBorder)
        imageView.draw(corner: theme.imageCorner)

        addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.top == 0
            $0.leading == 0
        }
    }

    private func addName(_ theme: WCSessionItemViewTheme) {
        nameView.customizeAppearance(theme.name)

        addSubview(nameView)
        nameView.snp.makeConstraints {
            $0.top == 0
            $0.leading == imageView.snp.trailing + theme.nameHorizontalPadding
        }
    }

    private func addOptionsAction(_ theme: WCSessionItemViewTheme) {
        optionsActionView.customizeAppearance(theme.optionsAction)

        addSubview(optionsActionView)
        optionsActionView.fitToIntrinsicSize()
        optionsActionView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= nameView.snp.trailing + theme.nameHorizontalPadding
            $0.trailing == 0
        }

        startPublishing(
            event: .performOptions,
            for: optionsActionView
        )
    }

    private func addDescription(_ theme: WCSessionItemViewTheme) {
        descriptionView.customizeAppearance(theme.description)

        addSubview(descriptionView)
        descriptionView.contentEdgeInsets.top = theme.descriptionTopPadding
        descriptionView.fitToIntrinsicSize()
        descriptionView.snp.makeConstraints {
            $0.leading == nameView
            $0.top == nameView.snp.bottom
            $0.trailing == 0
        }
    }

    private func addDate(_ theme: WCSessionItemViewTheme) {
        dateView.customizeAppearance(theme.date)

        addSubview(dateView)
        dateView.fitToIntrinsicSize()
        dateView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.dateTopPadding
            $0.leading == nameView
            $0.trailing == 0
        }
    }

    private func addStatus(_ theme: WCSessionItemViewTheme) {
        statusView.customizeAppearance(theme.status)

        addSubview(statusView)
        statusView.contentEdgeInsets = theme.statusContentEdgeInsets
        statusView.fitToIntrinsicSize()
        statusView.snp.makeConstraints {
            $0.top == dateView.snp.bottom + theme.statusTopPadding
            $0.leading == nameView
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
}

extension WCSessionItemView {
    enum Event {
        case performOptions
    }
}
