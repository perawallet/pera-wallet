// Copyright 2019 Algorand, Inc.

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
//  ScreenshotWarningView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class ScreenshotWarningView: View {
    weak var delegate: ScreenshotWarningViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var descriptionLabel = UILabel()
    private lazy var closeButton = Button()

    func customize(_ theme: ScreenShotWarningViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addCloseButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
}

extension ScreenshotWarningView {
    private func addImageView(_ theme: ScreenShotWarningViewTheme) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.fitToSize(theme.imageSize)
        }
    }

    private func addTitleLabel(_ theme: ScreenShotWarningViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(_ theme: ScreenShotWarningViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addCloseButton(_ theme: ScreenShotWarningViewTheme) {
        closeButton.customize(theme.closeButtonTheme)
        closeButton.bindData(ButtonCommonViewModel(title: "title-close".localized))

        addSubview(closeButton)
        closeButton.fitToVerticalIntrinsicSize()
        closeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(theme.verticalInset)
        }
    }
}

extension ScreenshotWarningView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.screenshotWarningViewDidCloseScreen(self)
    }
}

protocol ScreenshotWarningViewDelegate: AnyObject {
    func screenshotWarningViewDidCloseScreen(_ screenshotWarningView: ScreenshotWarningView)
}
