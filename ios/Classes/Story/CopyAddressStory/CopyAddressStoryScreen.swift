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

//   CopyAddressStoryScreen.swift

import Foundation
import MacaroonStorySheet
import MacaroonUIKit
import UIKit

/// <todo>
/// Convert it to a generic component and name it PopupScreen, and support all variants.
final class CopyAddressStoryScreen:
    ScrollScreen,
    AlertUIScrollContentConfigurable {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?

    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var imageView = ImageView()
    private lazy var titleLabel = Label()
    private lazy var descriptionLabel = Label()
    
    private lazy var closeActionView =
        ViewFactory.Button.makeSecondaryButton(theme.closeButtonTitle)

    private let theme: CopyAddressStoryScreenTheme
    
    init(
        configuration: ViewControllerConfiguration,
        theme: CopyAddressStoryScreenTheme = .init()
    ) {
        self.theme = theme
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addImage()
        addTitle()
        addDescription()
        addCloseAction()
    }
}

extension CopyAddressStoryScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addImage() {
        imageView.customizeAppearance(theme.image)

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == theme.imageTopInset
            $0.leading >= theme.imageMinHorizontalInsets.leading
            $0.trailing <= theme.imageMinHorizontalInsets.trailing
        }
    }
    
    private func addTitle() {
        titleLabel.customizeAppearance(theme.title)

        contentView.addSubview(titleLabel)
        titleLabel.fitToVerticalIntrinsicSize()
        titleLabel.snp.makeConstraints {
            $0.top == imageView.snp.bottom + theme.titleTopInset
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
        }
    }
    
    private func addDescription() {
        descriptionLabel.customizeAppearance(theme.description)

        contentView.addSubview(descriptionLabel)
        descriptionLabel.fitToVerticalIntrinsicSize()
        descriptionLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.descriptionVerticalMargins.top
            $0.leading == theme.defaultInset
            $0.bottom == 0
            $0.trailing == theme.defaultInset
        }
    }
    
    private func addCloseAction() {
        footerView.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.fitToHeight(theme.closeButtonHeight)
            $0.top == theme.closeButtonPaddings.top
            $0.leading == theme.closeButtonPaddings.left
            $0.bottom == theme.closeButtonPaddings.bottom
            $0.trailing == theme.closeButtonPaddings.right
        }
        
        closeActionView.addTouch(
            target: self,
            action: #selector(close)
        )
    }
}

extension CopyAddressStoryScreen {
    @objc
    private func close() {
        eventHandler?(.close)
    }
}

extension CopyAddressStoryScreen {
    enum Event {
        case close
    }
}
