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

final class WCSessionItemView: View {
    weak var delegate: WCSessionItemViewDelegate?

    private lazy var dappImageView = URLImageView()
    private lazy var nameLabel = UILabel()
    private lazy var disconnectOptionsButton = UIButton()
    private lazy var descriptionLabel = UILabel()
    private lazy var statusLabel = UILabel()
    private lazy var dateLabel = UILabel()

     func setListeners() {
        disconnectOptionsButton.addTarget(self, action: #selector(notifyDelegateToOpenDisconnectionMenu), for: .touchUpInside)
    }

    func customize(_ theme: WCSessionItemViewTheme) {
        addDappImageView(theme)
        addDisconnectOptionsButton(theme)
        addNameLabel(theme)
        addDescriptionLabel(theme)
        addDateLabel(theme)
        addStatusLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension WCSessionItemView {
    private func addDappImageView(_ theme: WCSessionItemViewTheme) {
        dappImageView.build(URLImageViewNoStyleLayoutSheet())
        dappImageView.draw(border: theme.imageBorder)
        dappImageView.draw(corner: theme.imageCorner)

        addSubview(dappImageView)
        dappImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.imageSize)
            $0.top.equalToSuperview().inset(theme.imageTopInset)
        }
    }

    private func addDisconnectOptionsButton(_ theme: WCSessionItemViewTheme) {
        disconnectOptionsButton.customizeAppearance(theme.disconnectOptionsButton)

        addSubview(disconnectOptionsButton)
        disconnectOptionsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.fitToSize(theme.disconnectOptionsButtonSize)
            $0.top.equalToSuperview()
        }
    }

    private func addNameLabel(_ theme: WCSessionItemViewTheme) {
        nameLabel.customizeAppearance(theme.nameLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(dappImageView.snp.trailing).offset(theme.nameLabelHorizontalInset)
            $0.trailing.equalTo(disconnectOptionsButton.snp.leading).offset(-theme.nameLabelHorizontalInset)
            $0.top.equalTo(dappImageView.snp.top)
        }
    }

    private func addDescriptionLabel(_ theme: WCSessionItemViewTheme) {
        descriptionLabel.customizeAppearance(theme.descriptionLabel)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDateLabel(_ theme: WCSessionItemViewTheme) {
        dateLabel.customizeAppearance(theme.dateLabel)

        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.dateLabelTopInset)
        }
    }

    private func addStatusLabel(_ theme: WCSessionItemViewTheme) {
        statusLabel.customizeAppearance(theme.statusLabel)
        statusLabel.layer.cornerRadius = theme.statusLabelCorner.radius
        statusLabel.layer.masksToBounds = true

        addSubview(statusLabel)
        statusLabel.snp.makeConstraints {
            $0.leading.equalTo(dateLabel)
            $0.top.equalTo(dateLabel.snp.bottom).offset(theme.statusLabelTopInset)
            $0.fitToSize(theme.statusLabelSize)
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension WCSessionItemView {
    @objc
    private func notifyDelegateToOpenDisconnectionMenu() {
        delegate?.wcSessionItemViewDidOpenDisconnectionMenu(self)
    }
}

extension WCSessionItemView: ViewModelBindable {
    func bindData(_ viewModel: WCSessionItemViewModel?) {
        dappImageView.load(from: viewModel?.image)
        nameLabel.text = viewModel?.name
        descriptionLabel.text = viewModel?.description
        statusLabel.text = viewModel?.status
        dateLabel.text = viewModel?.date
    }

    func prepareForReuse() {
        dappImageView.prepareForReuse()
        nameLabel.text = nil
        descriptionLabel.text = nil
        statusLabel.text = nil
        dateLabel.text = nil
    }
}

protocol WCSessionItemViewDelegate: AnyObject {
    func wcSessionItemViewDidOpenDisconnectionMenu(_ wcSessionItemView: WCSessionItemView)
}
