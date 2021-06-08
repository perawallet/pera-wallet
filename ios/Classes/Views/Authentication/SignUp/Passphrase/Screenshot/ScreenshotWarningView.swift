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

class ScreenshotWarningView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: ScreenshotWarningViewDelegate?

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
            .withText("screenshot-title".localized)
    }()

    private lazy var imageView = UIImageView(image: img("img-warning-circle"))

    private lazy var descriptionLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("screenshot-description".localized)
    }()

    private lazy var closeButton = MainButton(title: "title-accept".localized)

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupDescriptionLabelLayout()
        setupCloseButtonLayout()
    }
}

extension ScreenshotWarningView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupImageViewLayout() {
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }

    private func setupDescriptionLabelLayout() {
        addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.descriptionTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupCloseButtonLayout() {
        addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.topInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
}

extension ScreenshotWarningView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.screenshotWarningViewDidCloseScreen(self)
    }
}

extension ScreenshotWarningView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 16.0
        let descriptionTopInset: CGFloat = 20.0
        let imageSize = CGSize(width: 80.0, height: 80.0)
    }
}

protocol ScreenshotWarningViewDelegate: class {
    func screenshotWarningViewDidCloseScreen(_ screenshotWarningView: ScreenshotWarningView)
}
