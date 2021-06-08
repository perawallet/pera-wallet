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
//  MaximumBalanceWarningView.swift

import UIKit

class MaximumBalanceWarningView: BaseView {

    weak var delegate: MaximumBalanceWarningViewDelegate?

    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
            .withText("min-balance-title".localized)
    }()

    private lazy var imageView = UIImageView(image: img("img-warning-circle"))

    private lazy var descriptionLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()

    private lazy var continueButton = MainButton(title: "title-continue".localized)

    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withTitleColor(Colors.ButtonText.tertiary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        continueButton.addTarget(self, action: #selector(notifyDelegateToConfirmWarning), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancel), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupDescriptionLabelLayout()
        setupContinueButtonLayout()
        setupCancelButtonLayout()
    }
}

extension MaximumBalanceWarningView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
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
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.descriptionVerticalInset)
        }
    }

    private func setupContinueButtonLayout() {
        addSubview(continueButton)

        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)

        cancelButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(continueButton.snp.bottom).offset(layout.current.buttonInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension MaximumBalanceWarningView {
    @objc
    private func notifyDelegateToConfirmWarning() {
        delegate?.maximumBalanceWarningViewDidConfirmWarning(self)
    }

    @objc
    private func notifyDelegateToCancel() {
        delegate?.maximumBalanceWarningViewDidCancel(self)
    }
}

extension MaximumBalanceWarningView {
    func bind(_ viewModel: MaximumBalanceWarningViewModel) {
        descriptionLabel.text = viewModel.description
    }
}

extension MaximumBalanceWarningView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageSize = CGSize(width: 80.0, height: 80.0)
        let topInset: CGFloat = 16.0
        let descriptionVerticalInset: CGFloat = 20.0
        let buttonInset: CGFloat = 12.0
        let verticalInset: CGFloat = 28.0
        let buttonHeight: CGFloat = 52.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol MaximumBalanceWarningViewDelegate: class {
    func maximumBalanceWarningViewDidConfirmWarning(_ maximumBalanceWarningView: MaximumBalanceWarningView)
    func maximumBalanceWarningViewDidCancel(_ maximumBalanceWarningView: MaximumBalanceWarningView)
}
