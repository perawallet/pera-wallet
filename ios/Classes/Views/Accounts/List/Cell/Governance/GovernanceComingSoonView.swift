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
//   GovernanceComingSoonView.swift

import UIKit

class GovernanceComingSoonView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: GovernanceComingSoonViewDelegate?

    private lazy var containerView = UIView()

    private lazy var imageView = UIImageView(image: img("governance-algo-icon"))

    private lazy var closeButton: UIButton = {
        UIButton(type: .custom).withImage(img("close-governance-icon"))
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("Become a governor. Vote on Algorand’s future. Earn rewards.")
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("The registration window for Governance Period #2 is Dec. 24 to Jan. 6, 16:00 UTC")
    }()

    private lazy var getStartedButton: AlignedButton = {
        let button = AlignedButton(.imageAtRight(spacing: 8.0))
        button.setImage(img("icon-arrow", isTemplate: true), for: .normal)
        button.tintColor = Colors.ButtonText.actionButton
        button.setTitle("governance-banner-action".localized, for: .normal)
        button.setTitleColor(Colors.ButtonText.actionButton, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.titleLabel?.textAlignment = .left
        return button
    }()

    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = Colors.Background.secondary
        containerView.layer.cornerRadius = 12.0
    }

    override func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToCancelView), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(notifyDelegateToGetStarted), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupContainerViewLayout()
        setupImageViewLayout()
        setupCloseButtonLayout()
        setupTitleLabelLayout()
        setupDetailLabelLayout()
        setupGetStartedButtonLayout()
    }
}

extension GovernanceComingSoonView {
    @objc
    private func notifyDelegateToCancelView() {
        delegate?.governanceComingSoonViewDidTapCancelButton(self)
    }

    @objc
    private func notifyDelegateToGetStarted() {
        delegate?.governanceComingSoonViewDidTapGetStartedButton(self)
    }
}

extension GovernanceComingSoonView {
    private func setupContainerViewLayout() {
        addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.containerBottomInset)
        }
    }

    private func setupImageViewLayout() {
        containerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }

    private func setupCloseButtonLayout() {
        containerView.addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }

    private func setupTitleLabelLayout() {
        containerView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.horizontalInset)
            make.top.equalTo(imageView)
            make.trailing.equalTo(closeButton.snp.leading).offset(layout.current.titleTrailingOffset)
        }
    }

    private func setupDetailLabelLayout() {
        containerView.addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.detailTopInset)
        }
    }

    private func setupGetStartedButtonLayout() {
        containerView.addSubview(getStartedButton)

        getStartedButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.buttonTopInset)
        }
    }
}

extension GovernanceComingSoonView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 24.0
        let imageSize = CGSize(width: 44.0, height: 44.0)
        let detailTopInset: CGFloat = 8.0
        let containerBottomInset: CGFloat = 24.0
        let buttonTopInset: CGFloat = 12.0
        let titleTrailingOffset: CGFloat = -12.0
    }
}

protocol GovernanceComingSoonViewDelegate: AnyObject {
    func governanceComingSoonViewDidTapGetStartedButton(_ governanceComingSoonView: GovernanceComingSoonView)
    func governanceComingSoonViewDidTapCancelButton(_ governanceComingSoonView: GovernanceComingSoonView)
}
