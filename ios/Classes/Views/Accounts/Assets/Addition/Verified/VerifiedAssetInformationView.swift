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
//  VerifiedAssetInformationView.swift

import UIKit

class VerifiedAssetInformationView: BaseView {
    
    weak var delegate: VerifiedAssetInformationViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var labelTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenFeedback(_:))
    )
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
            .withText("verified-asset-information-title".localized)
            .withLine(.contained)
    }()
    
    private lazy var verifiedImageView = UIImageView(image: img("icon-verified"))
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
            .withLine(.contained)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func setListeners() {
        informationLabel.addGestureRecognizer(labelTapGestureRecognizer)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
        addInformationTextAttributes()
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupVerifiedImageViewLayout()
        setupInformationLabelLayout()
    }
}

extension VerifiedAssetInformationView {
    @objc
    private func notifyDelegateToOpenFeedback(_ gestureRecognizer: UITapGestureRecognizer) {
        let fullText = "verified-asset-information-text".localized as NSString
        let contactTextRange = fullText.range(of: "verified-asset-information-visit-site".localized)

        if gestureRecognizer.detectTouchForLabel(informationLabel, in: contactTextRange) {
            delegate?.verifiedAssetInformationViewDidVisitSite(self)
        }
    }
}

extension VerifiedAssetInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.imageLeadingOffset)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    private func setupInformationLabelLayout() {
        addSubview(informationLabel)
        
        informationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension VerifiedAssetInformationView {
    private func addInformationTextAttributes() {
        let fullText = "verified-asset-information-text".localized
        let doubleCheckText = "verified-asset-double-check".localized
        let contactText = "verified-asset-information-visit-site".localized
        
        let fullAttributedText = NSMutableAttributedString(string: fullText)
        
        let doubleCheckTextRange = (fullText as NSString).range(of: doubleCheckText)
        fullAttributedText.addAttribute(.foregroundColor, value: Colors.General.verified, range: doubleCheckTextRange)
        
        let contactTextRange = (fullText as NSString).range(of: contactText)
        fullAttributedText.addAttribute(.foregroundColor, value: Colors.ButtonText.actionButton, range: contactTextRange)
        
        informationLabel.attributedText = fullAttributedText
    }
}

extension VerifiedAssetInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 28.0
        let imageLeadingOffset: CGFloat = 12.0
    }
}

protocol VerifiedAssetInformationViewDelegate: class {
    func verifiedAssetInformationViewDidVisitSite(_ verifiedAssetInformationView: VerifiedAssetInformationView)
}
