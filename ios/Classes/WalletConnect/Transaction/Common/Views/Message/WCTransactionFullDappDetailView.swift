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
//   WCTransactionFullDappDetailView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCTransactionFullDappDetailView: View {
    weak var delegate: WCTransactionFullDappDetailViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var imageView = URLImageView()
    private lazy var descriptionLabel = UILabel()
    private lazy var verticalStackView = UIStackView()
    private lazy var primaryActionButton = MacaroonUIKit.Button()
    private lazy var secondaryActionButton = MacaroonUIKit.Button()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: WCTransactionFullDappDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addVerticalStackView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        primaryActionButton.addTarget(self, action: #selector(notifyDelegateToHandlePrimaryActionButton), for: .touchUpInside)
    }
}

extension WCTransactionFullDappDetailView {
    private func addImageView(_ theme: WCTransactionFullDappDetailViewTheme) {
        imageView.build(theme.image)
        imageView.draw(corner: theme.imageCorner)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.fitToSize(theme.imageSize)
        }
    }

    private func addTitleLabel(_ theme: WCTransactionFullDappDetailViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.titleLeadingInset)
            $0.centerY == imageView
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(_ theme: WCTransactionFullDappDetailViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addVerticalStackView(_ theme: WCTransactionFullDappDetailViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.spacing = theme.buttonInset
        verticalStackView.axis = .vertical

        verticalStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.verticalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }

        addPrimaryActionButton(theme)
    }

    private func addPrimaryActionButton(_ theme: WCTransactionFullDappDetailViewTheme) {
        primaryActionButton.customizeAppearance(theme.primaryAction)
        primaryActionButton.contentEdgeInsets = UIEdgeInsets(theme.primaryActionEdgeInsets)

        primaryActionButton.fitToVerticalIntrinsicSize()
        verticalStackView.addArrangedSubview(primaryActionButton)
    }
}

extension WCTransactionFullDappDetailView {
    func bindData(_ configurator: WCTransactionFullDappDetailConfigurator?) {
        titleLabel.text = configurator?.title
        descriptionLabel.text = configurator?.description
        imageView.load(from: configurator?.image)
        primaryActionButton.setTitle(configurator?.primaryActionButtonTitle, for: .normal)
    }
}

extension WCTransactionFullDappDetailView {
    @objc
    private func notifyDelegateToHandlePrimaryActionButton() {
        delegate?.wcTransactionFullDappDetailViewDidTapPrimaryActionButton(self)
    }

}

protocol WCTransactionFullDappDetailViewDelegate: AnyObject {
    func wcTransactionFullDappDetailViewDidTapPrimaryActionButton(_ view: WCTransactionFullDappDetailView)
}
