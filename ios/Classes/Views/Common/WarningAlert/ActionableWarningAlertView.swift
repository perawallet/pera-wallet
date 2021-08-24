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
//   ActionableWarningAlertView.swift

import UIKit

class ActionableWarningAlertView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: ActionableWarningAlertViewDelegate?

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
    }()

    private lazy var imageView = UIImageView(image: img("img-warning-circle"))

    private lazy var descriptionLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
    }()

    private lazy var actionButton = MainButton(title: "")

    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.Text.primary)
    }()

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupDescriptionLabelLayout()
        setupActionButtonLayout()
        setupCancelButtonLayout()
    }

    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToTakeAction), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancel), for: .touchUpInside)
    }

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
}

extension ActionableWarningAlertView {
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

    private func setupActionButtonLayout() {
        addSubview(actionButton)

        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)

        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.topInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(actionButton.snp.bottom).offset(layout.current.buttonVerticalInset)
        }
    }
}

extension ActionableWarningAlertView {
    @objc
    private func notifyDelegateToTakeAction() {
        delegate?.actionableWarningAlertViewDidTakeAction(self)
    }

    @objc
    private func notifyDelegateToCancel() {
        delegate?.actionableWarningAlertViewDidCancel(self)
    }
}

extension ActionableWarningAlertView {
    func bind(_ viewModel: WarningAlertViewModel) {
        titleLabel.text = viewModel.title
        imageView.image = viewModel.image
        descriptionLabel.text = viewModel.description
        actionButton.setTitle(viewModel.actionTitle, for: .normal)
    }
}

extension ActionableWarningAlertView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 16.0
        let descriptionTopInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 12.0
        let imageSize = CGSize(width: 80.0, height: 80.0)
    }
}

protocol ActionableWarningAlertViewDelegate: AnyObject {
    func actionableWarningAlertViewDidTakeAction(_ actionableWarningAlertView: ActionableWarningAlertView)
    func actionableWarningAlertViewDidCancel(_ actionableWarningAlertView: ActionableWarningAlertView)
}
