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
//   TransactionTutorialView.swift

import UIKit
import Lottie

class TransactionTutorialView: BaseView {

    weak var delegate: TransactionTutorialViewDelegate?

    private let layout = Layout<LayoutConstants>()

    private lazy var moreInfoTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenMoreInfo)
    )

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
            .withText("transaction-tutorial-title".localized)
    }()

    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()

    private lazy var walletImageView: AnimationView = {
        let walletImageView = AnimationView()
        walletImageView.contentMode = .scaleAspectFit
        walletImageView.backgroundColor = .clear
        let animation = Animation.named("account_animation")
        walletImageView.animation = animation
        return walletImageView
    }()

    private lazy var leftDeviceImageView = UIImageView(image: img("img-device-gray"))

    private lazy var rightDeviceImageView = UIImageView(image: img("img-device-green"))

    private lazy var numberOneView: TutorialNumberView = {
        let numberView = TutorialNumberView()
        numberView.bind(TutorialNumberViewModel(number: 1))
        return numberView
    }()

    private lazy var firstTipLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withText("transaction-tutorial-tip-first".localized)
    }()

    private lazy var numberTwoView: TutorialNumberView = {
        let numberView = TutorialNumberView()
        numberView.bind(TutorialNumberViewModel(number: 2))
        return numberView
    }()

    private lazy var secondTipLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()

    private lazy var separatorView = LineSeparatorView()

    private lazy var tapToMoreLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
        label.isUserInteractionEnabled = true
        return label
    }()

    private lazy var confirmButton = MainButton(title: "title-i-understand".localized)

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func setListeners() {
        tapToMoreLabel.addGestureRecognizer(moreInfoTapGestureRecognizer)
        confirmButton.addTarget(self, action: #selector(notifyDelegateToConfirmWarning), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupWalletImageViewLayout()
        setupRightDeviceImageViewLayout()
        setupLeftDeviceImageViewLayout()
        setupNumberOneViewLayout()
        setupFirstTipLabelLayout()
        setupNumberTwoViewLayout()
        setupSecondTipLabelLayout()
        setupSeparatorViewLayout()
        setupTapToMoreLabelLayout()
        setupConfirmButtonLayout()
    }
}

extension TransactionTutorialView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
        }
    }

    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleVerticalInset)
        }
    }

    private func setupWalletImageViewLayout() {
        addSubview(walletImageView)

        walletImageView.snp.makeConstraints { make in
            make.centerX.equalTo(titleLabel)
            make.size.equalTo(layout.current.bluetoothImageSize)
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.bluetoothTopInset)
        }
    }

    private func setupRightDeviceImageViewLayout() {
        addSubview(rightDeviceImageView)

        rightDeviceImageView.snp.makeConstraints { make in
            make.leading.equalTo(walletImageView.snp.trailing).offset(layout.current.deviceImageInset)
            make.centerY.equalTo(walletImageView)
        }
    }

    private func setupLeftDeviceImageViewLayout() {
        addSubview(leftDeviceImageView)

        leftDeviceImageView.snp.makeConstraints { make in
            make.centerY.equalTo(walletImageView)
            make.trailing.equalTo(walletImageView.snp.leading).offset(-layout.current.deviceImageInset)
        }
    }

    private func setupNumberOneViewLayout() {
        addSubview(numberOneView)

        numberOneView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.numberSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(leftDeviceImageView.snp.bottom).offset(layout.current.tipOneVerticalInset)
        }
    }

    private func setupFirstTipLabelLayout() {
        addSubview(firstTipLabel)

        firstTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberOneView.snp.trailing).offset(layout.current.tipHorizontalInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(numberOneView)
        }
    }

    private func setupNumberTwoViewLayout() {
        addSubview(numberTwoView)

        numberTwoView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.numberSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(firstTipLabel.snp.bottom).offset(layout.current.tipTwoVerticalInset)
        }
    }

    private func setupSecondTipLabelLayout() {
        addSubview(secondTipLabel)

        secondTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberTwoView.snp.trailing).offset(layout.current.tipHorizontalInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(numberTwoView)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(secondTipLabel.snp.bottom).offset(layout.current.separatorTopInset)
        }
    }

    private func setupTapToMoreLabelLayout() {
        addSubview(tapToMoreLabel)

        tapToMoreLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.topToMoreTopInset)
        }
    }

    private func setupConfirmButtonLayout() {
        addSubview(confirmButton)

        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.greaterThanOrEqualTo(tapToMoreLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension TransactionTutorialView {
    func bind(_ viewModel: TransactionTutorialViewModel) {
        subtitleLabel.text = viewModel.subtitle
        secondTipLabel.attributedText = viewModel.secondTip
        tapToMoreLabel.attributedText = viewModel.tapToMoreText

        if let animationName = viewModel.animationName {
            walletImageView.animation = Animation.named(animationName)
        }
    }

    func startAnimating() {
        walletImageView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }

    func stopAnimating() {
        walletImageView.stop()
    }
}

extension TransactionTutorialView {
    @objc
    private func notifyDelegateToConfirmWarning() {
        delegate?.transactionTutorialViewDidConfirmTutorial(self)
    }

    @objc
    private func notifyDelegateToOpenMoreInfo() {
        delegate?.transactionTutorialViewDidOpenMoreInfo(self)
    }
}

extension TransactionTutorialView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 16.0
        let subtitleHorizontalInset: CGFloat = 24.0
        let subtitleVerticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
        let tipOneVerticalInset: CGFloat = 52.0
        let tipTwoVerticalInset: CGFloat = 24.0
        let tipHorizontalInset: CGFloat = 12.0
        let numberSize = CGSize(width: 32.0, height: 32.0)
        let bluetoothImageSize = CGSize(width: 155.0, height: 44.0)
        let deviceImageInset: CGFloat = 8.0
        let bluetoothTopInset: CGFloat = 44.0
        let topToMoreTopInset: CGFloat = 32.0
        let buttonTopInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let separatorTopInset: CGFloat = 40.0
    }
}

protocol TransactionTutorialViewDelegate: class {
    func transactionTutorialViewDidConfirmTutorial(_ transactionTutorialView: TransactionTutorialView)
    func transactionTutorialViewDidOpenMoreInfo(_ transactionTutorialView: TransactionTutorialView)
}
