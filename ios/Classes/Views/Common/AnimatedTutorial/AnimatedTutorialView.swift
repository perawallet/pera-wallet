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
//  AnimatedTutorialView.swift

import UIKit

class AnimatedTutorialView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: AnimatedTutorialViewDelegate?

    private lazy var animatedImageView = LottieImageView()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
    }()

    private lazy var descriptionLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.center)
    }()

    private lazy var mainButton = MainButton(title: "")

    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.ButtonText.secondary)
    }()

    private let isActionable: Bool

    init(isActionable: Bool) {
        self.isActionable = isActionable
        super.init(frame: .zero)
    }

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func setListeners() {
        mainButton.addTarget(self, action: #selector(notifyDelegateToTutorialApprovaed), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(notifyDelegateToTakeAction), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupAnimatedImageViewLayout()
        setupTitleLabelLayout()
        setupDescriptionLabelLayout()
        setupMainButtonLayout()
        if isActionable {
            setupActionButtonLayout()
        }
    }
}

extension AnimatedTutorialView {
    @objc
    private func notifyDelegateToTutorialApprovaed() {
        delegate?.animatedTutorialViewDidApproveTutorial(self)
    }

    @objc
    private func notifyDelegateToTakeAction() {
        delegate?.animatedTutorialViewDidTakeAction(self)
    }
}

extension AnimatedTutorialView {
    private func setupAnimatedImageViewLayout() {
        addSubview(animatedImageView)

        animatedImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height / 4 - 44.0 - safeAreaTop)
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(animatedImageView.snp.bottom).offset(layout.current.titleTopInset)
        }
    }

    private func setupDescriptionLabelLayout() {
        addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.descriptionHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.descriptionTopInset)
        }
    }

    private func setupMainButtonLayout() {
        addSubview(mainButton)

        mainButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(layout.current.buttonInset)

            if !isActionable {
                make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
            }
        }
    }

    private func setupActionButtonLayout() {
        addSubview(actionButton)

        actionButton.snp.makeConstraints { make in

            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(mainButton.snp.bottom).offset(layout.current.buttonInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension AnimatedTutorialView {
    func startAnimating(with configuration: LottieConfiguration) {
        animatedImageView.show(with: configuration)
    }

    func stopAnimating() {
        animatedImageView.stop()
    }
}

extension AnimatedTutorialView {
    func bind(_ viewModel: AnimatedTutorialViewModel) {
        if let animation = viewModel.animation {
            animatedImageView.setAnimation(animation)
        }

        titleLabel.text = viewModel.title
        descriptionLabel.attributedText = viewModel.description
        descriptionLabel.textAlignment = .center
        mainButton.setTitle(viewModel.mainTitle, for: .normal)
        actionButton.setTitle(viewModel.actionTitle, for: .normal)
    }
}

extension AnimatedTutorialView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 20.0
        let descriptionHorizontalInset: CGFloat = 24.0
        let descriptionTopInset: CGFloat = 16.0
        let buttonInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol AnimatedTutorialViewDelegate: AnyObject {
    func animatedTutorialViewDidApproveTutorial(_ animatedTutorialView: AnimatedTutorialView)
    func animatedTutorialViewDidTakeAction(_ animatedTutorialView: AnimatedTutorialView)
}
