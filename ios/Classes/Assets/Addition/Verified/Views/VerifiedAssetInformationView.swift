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
//  VerifiedAssetInformationView.swift

import UIKit
import MacaroonUIKit

final class VerifiedAssetInformationView: View {
    weak var delegate: VerifiedAssetInformationViewDelegate?
    
    private lazy var labelTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenFeedback(_:))
    )
    
    private lazy var titleLabel = UILabel()
    private lazy var informationLabel = UILabel()
    private lazy var verifiedImageView = UIImageView()
    
    func customize(_ theme: VerifiedAssetInformationViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitle(theme)
        addImage(theme)
        addInformation(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func setListeners() {
        informationLabel.addGestureRecognizer(labelTapGestureRecognizer)
    }
}

extension VerifiedAssetInformationView {
    private func addTitle(_ theme: VerifiedAssetInformationViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalInset)
        }
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func addImage(_ theme: VerifiedAssetInformationViewTheme) {
        verifiedImageView.customizeAppearance(theme.image)
        
        addSubview(verifiedImageView)
        verifiedImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(theme.imageLeadingOffset)
            $0.centerY.equalTo(titleLabel)
        }
    }
    
    private func addInformation(_ theme: VerifiedAssetInformationViewTheme) {
        informationLabel.isUserInteractionEnabled = true
        informationLabel.customizeAppearance(theme.information)
        
        addSubview(informationLabel)
        
        informationLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.verticalSpacing)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension VerifiedAssetInformationView {
    @objc
    private func notifyDelegateToOpenFeedback(_ gestureRecognizer: UITapGestureRecognizer) {
        let fullText = "verified-asset-information-text".localized(AlgorandWeb.support.presentation) as NSString
        let contactTextRange = fullText.range(of: AlgorandWeb.support.presentation)

        if gestureRecognizer.detectTouchForLabel(informationLabel, in: contactTextRange) {
            delegate?.verifiedAssetInformationViewDidVisitSite(self)
        }
    }
}

protocol VerifiedAssetInformationViewDelegate: AnyObject {
    func verifiedAssetInformationViewDidVisitSite(_ verifiedAssetInformationView: VerifiedAssetInformationView)
}
