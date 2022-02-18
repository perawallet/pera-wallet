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
//   BannerView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class BannerView: View, ViewModelBindable {
    var completion: (() -> Void)? {
        didSet {
            addBannerTapGesture()
        }
    }

    private lazy var horizontalStackView = UIStackView()
    private lazy var verticalStackView = VStackView()
    private lazy var titleLabel = Label()
    private lazy var messageLabel = Label()
    private lazy var iconView = UIImageView()

    func customize(_ theme: BannerViewTheme) {
        addHorizontalStackView(theme)
        addIcon(theme)
        addVerticalStackView(theme)
        addTitle(theme)
        addMessage(theme)
        
        drawAppearance(shadow: theme.backgroundShadow)
        
        guard let background = theme.background,
              let corner = theme.corner else {
            return
        }
        customizeAppearance(background)
        draw(corner: corner)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func bindData(_ viewModel: BannerViewModel?) {
        bindTitle(viewModel)
        bindMessage(viewModel)
        bindIcon(viewModel)
    }
}

extension BannerView {
    private func addBannerTapGesture() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBanner)))
    }

    @objc
    private func didTapBanner() {
        completion?()
    }
}

extension BannerView {
    private func addHorizontalStackView(_ theme: BannerViewTheme) {
        addSubview(horizontalStackView)

        horizontalStackView.spacing = theme.horizontalStackViewSpacing
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.alignment = .top

        horizontalStackView.snp.makeConstraints {
            $0.setPaddings(
                theme.horizontalStackViewPaddings
            )
        }
    }

    private func addVerticalStackView(_ theme: BannerViewTheme) {
        horizontalStackView.addArrangedSubview(verticalStackView)

        verticalStackView.spacing = theme.verticalStackViewSpacing
    }

    private func addTitle(_ theme: BannerViewTheme) {
        guard let titleTextStyle = theme.title else {
            return
        }
        
        titleLabel.customizeAppearance(titleTextStyle)

        verticalStackView.addArrangedSubview(titleLabel)
    }

    private func addMessage(_ theme: BannerViewTheme) {
        guard let messageTextStyle = theme.message else {
            return
        }
        
        messageLabel.customizeAppearance(messageTextStyle)

        verticalStackView.addArrangedSubview(messageLabel)
    }

    private func addIcon(_ theme: BannerViewTheme) {
        guard let iconImageStyle = theme.icon else {
            return
        }
        iconView.customizeAppearance(iconImageStyle)

        horizontalStackView.addArrangedSubview(iconView)
        
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
        }
    }
}

extension BannerView {
    private func bindTitle(_ viewModel: BannerViewModel?) {
        titleLabel.editText = viewModel?.title
    }
    
    private func bindMessage(_ viewModel: BannerViewModel?) {
        messageLabel.editText = viewModel?.message
    }

    private func bindIcon(_ viewModel: BannerViewModel?) {
        iconView.image = viewModel?.icon?.uiImage
    }
}
