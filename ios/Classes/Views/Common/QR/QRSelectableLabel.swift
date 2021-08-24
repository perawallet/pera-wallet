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
//  QRSelectableLabel.swift

import UIKit

class QRSelectableLabel: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: QRSelectableLabelDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.QRSelectable.background
        view.layer.cornerRadius = 12.0
        return view
    }()

    private lazy var addressTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(Colors.Text.tertiary)
            .withLine(.single)
            .withText("qr-creation-address".localized)
    }()
    
    private lazy var addressLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
    }()
    
    private lazy var copyImageView = UIImageView(image: img("icon-copy"))
    
    private lazy var copyLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
            .withTextColor(Colors.ButtonText.actionButton)
            .withText("qr-creation-copy-address".localized)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private lazy var copiedFeedbackLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
            .withTextColor(Colors.QRSelectable.feedbackText)
            .withText("qr-creation-copied".localized)
            .withLine(.single)
            .withAlignment(.center)
        label.backgroundColor = Colors.QRSelectable.feedbackBackground
        label.layer.cornerRadius = 22.0
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notifyDelegateToCopyText)))
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupAddressTitleLabelLayout()
        setupAddressLabelLayout()
        setupCopyLabelLayout()
        setupCopyImageViewLayout()
        setupCopiedFeedbackLabelLayout()
    }
}

extension QRSelectableLabel {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func setupAddressTitleLabelLayout() {
        containerView.addSubview(addressTitleLabel)
        
        addressTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAddressLabelLayout() {
        containerView.addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(layout.current.addressLabelTopOffset)
        }
    }
    
    private func setupCopyLabelLayout() {
        containerView.addSubview(copyLabel)
        
        copyLabel.snp.makeConstraints { make in
            make.centerX.equalTo(containerView).offset(layout.current.copyLabelCenterOffset)
            make.top.equalTo(addressLabel.snp.bottom).offset(layout.current.copyLabelTopInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupCopyImageViewLayout() {
        containerView.addSubview(copyImageView)
        
        copyImageView.snp.makeConstraints { make in
            make.centerY.equalTo(copyLabel)
            make.trailing.equalTo(copyLabel.snp.leading).offset(layout.current.copyImageViewTrailingOffset)
        }
    }
    
    private func setupCopiedFeedbackLabelLayout() {
        addSubview(copiedFeedbackLabel)
        
        copiedFeedbackLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.feedbackLabelTopInset)
            make.size.equalTo(layout.current.feedbackLabelSize)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension QRSelectableLabel {
    @objc
    private func notifyDelegateToCopyText(gesture recognizer: UIGestureRecognizer) {
        guard let delegate = delegate,
            let text = addressLabel.text else {
            return
        }
        
        delegate.qrSelectableLabel(self, didTapText: text)
        
        copiedFeedbackLabel.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.copiedFeedbackLabel.isHidden = true
        }
    }
}

extension QRSelectableLabel {
    func setAddress(_ address: String) {
        addressLabel.text = address
    }
}

extension Colors {
    fileprivate enum QRSelectable {
        static let background = color("qrSelectableBackground")
        static let feedbackBackground = color("qrSelectableFeedbackBackground")
        static let feedbackText = color("white")
    }
}

extension QRSelectableLabel {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 20.0
        let addressLabelTopOffset: CGFloat = 8.0
        let copyLabelCenterOffset: CGFloat = 8.0
        let copyLabelTopInset: CGFloat = 12.0
        let copyImageViewTrailingOffset: CGFloat = -4.0
        let feedbackLabelSize = CGSize(width: 224.0, height: 44.0)
        let feedbackLabelTopInset: CGFloat = 22.0
    }
}

protocol QRSelectableLabelDelegate: AnyObject {
    func qrSelectableLabel(_ qrSelectableLabel: QRSelectableLabel, didTapText text: String)
}
