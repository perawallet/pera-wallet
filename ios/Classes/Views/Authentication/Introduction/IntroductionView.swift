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
//  IntroductionView.swift

import UIKit

class IntroductionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: IntroductionViewDelegate?
    
    private lazy var outerAnimatedImageView = UIImageView(image: img("img-introduction-bg-outer"))
    
    private lazy var middleAnimatedImageView = UIImageView(image: img("img-introduction-bg-middle"))
    
    private lazy var innerAnimatedImageView = UIImageView(image: img("img-introduction-bg-inner"))
    
    private lazy var introductionImageView = UIImageView(image: img("logo-introduction"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 24.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
    }()
    
    private lazy var addAccountButton = MainButton(title: "introduction-add-account-text".localized)
    
    private lazy var termsAndConditionsTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .link
        textView.textContainerInset = .zero
        textView.textAlignment = .center
        textView.linkTextAttributes = [
            .foregroundColor: Colors.Text.link,
            .underlineColor: UIColor.clear,
            .font: UIFont.font(withWeight: .regular(size: 14.0))
        ]
        return textView
    }()
    
    override func setListeners() {
        addAccountButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
    
    override func linkInteractors() {
        termsAndConditionsTextView.delegate = self
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
        introductionImageView.contentMode = .scaleAspectFit
        
        let centerParagraphStyle = NSMutableParagraphStyle()
        centerParagraphStyle.alignment = .center
        
        termsAndConditionsTextView.bindHtml(
            "introduction-title-terms-and-services".localized,
            with: [
                .font: UIFont.font(withWeight: .regular(size: 14.0)),
                .foregroundColor: Colors.Text.tertiary,
                .paragraphStyle: centerParagraphStyle
            ]
        )
    }
    
    override func prepareLayout() {
        setupOuterAnimatedImageViewLayout()
        setupMiddleAnimatedImageViewLayout()
        setupInnerAnimatedImageViewLayout()
        setupTitleLabelLayout()
        setupIntroductionImageViewLayout()
        setupTermsAndConditionsTextViewLayout()
        setupAddAccountButtonLayout()
    }
}

extension IntroductionView {
    private func setupOuterAnimatedImageViewLayout() {
        addSubview(outerAnimatedImageView)
        
        outerAnimatedImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(-layout.current.outerImageOffset)
            make.trailing.equalToSuperview().offset(layout.current.outerImageOffset)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.width.equalTo(outerAnimatedImageView.snp.height)
        }
    }
    
    private func setupMiddleAnimatedImageViewLayout() {
        addSubview(middleAnimatedImageView)
        
        middleAnimatedImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(-layout.current.middleImageOffset)
            make.trailing.equalToSuperview().offset(layout.current.middleImageOffset)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.width.equalTo(middleAnimatedImageView.snp.height)
        }
    }
    
    private func setupInnerAnimatedImageViewLayout() {
        addSubview(innerAnimatedImageView)
        
        innerAnimatedImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.innerImageOffset)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.width.equalTo(innerAnimatedImageView.snp.height)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.titleCenterOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupIntroductionImageViewLayout() {
        addSubview(introductionImageView)
        
        introductionImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-layout.current.verticalInset)
        }
    }
    
    private func setupTermsAndConditionsTextViewLayout() {
        addSubview(termsAndConditionsTextView)
        
        termsAndConditionsTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupAddAccountButtonLayout() {
        addSubview(addAccountButton)
        
        addAccountButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(termsAndConditionsTextView.snp.top).offset(-layout.current.verticalInset)
        }
    }
}

extension IntroductionView {
    func animateImages() {
        outerAnimatedImageView.rotate360Degrees(duration: 4.15, repeatCount: .greatestFiniteMagnitude, isClockwise: false)
        middleAnimatedImageView.rotate360Degrees(duration: 3.5, repeatCount: .greatestFiniteMagnitude, isClockwise: false)
        innerAnimatedImageView.rotate360Degrees(duration: 3.0, repeatCount: .greatestFiniteMagnitude, isClockwise: true)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

extension IntroductionView {
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.introductionViewDidAddAccount(self)
    }
}

extension IntroductionView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.introductionView(self, didOpen: URL)
        return false
    }
}

extension IntroductionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let outerImageOffset: CGFloat = 116.0
        let middleImageOffset: CGFloat = 36.0
        let innerImageOffset: CGFloat = 44.0
        let horizontalInset: CGFloat = 32.0
        let verticalInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
        let titleCenterOffset: CGFloat = 22.0
    }
}

protocol IntroductionViewDelegate: AnyObject {
    func introductionViewDidAddAccount(_ introductionView: IntroductionView)
    func introductionView(_ introductionView: IntroductionView, didOpen url: URL)
}
