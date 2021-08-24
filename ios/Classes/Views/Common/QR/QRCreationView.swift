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
//  QRCreationView.swift

import UIKit

class QRCreationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: QRCreationViewDelegate?
    
    private lazy var qrView = QRView(qrText: QRText(mode: draft.mode, address: draft.address, mnemonic: draft.mnemonic))
    
    private lazy var shareButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 8.0))
        button.setBackgroundImage(img("bg-main-button"), for: .normal)
        button.setImage(img("icon-share-24"), for: .normal)
        button.setTitle("title-share-qr".localized, for: .normal)
        button.setTitleColor(Colors.ButtonText.primary, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var qrSelectableLabel = QRSelectableLabel()
    
    private let draft: QRCreationDraft
    
    init(draft: QRCreationDraft) {
        self.draft = draft
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        qrSelectableLabel.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareQR), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupQRViewLayout()
        setupShareButtonLayout()
        setupQRSelectableLabelLayout()
    }
}

extension QRCreationView {
    @objc
    private func notifyDelegateToShareQR() {
        delegate?.qrCreationViewDidShare(self)
    }
}

extension QRCreationView {
    private func setupQRViewLayout() {
        addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(qrView.snp.width)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(layout.current.buttonTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            
            if draft.isSelectable {
                make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
            }
        }
    }
    
    private func setupQRSelectableLabelLayout() {
        if !draft.isSelectable {
            return
        }
        
        addSubview(qrSelectableLabel)
        
        qrSelectableLabel.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(layout.current.labelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension QRCreationView: QRSelectableLabelDelegate {
    func qrSelectableLabel(_ qrSelectableLabel: QRSelectableLabel, didTapText text: String) {
        delegate?.qrCreationView(self, didSelect: text)
    }
}

extension QRCreationView {
    func setAddress(_ address: String) {
        qrSelectableLabel.setAddress(address)
    }
    
    func getQRImage() -> UIImage? {
        return qrView.imageView.image
    }
}

extension QRCreationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 70.0
        let buttonTopInset: CGFloat = 40.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 20.0
        let labelTopInset: CGFloat = 60.0
        let shareButtonWidth: CGFloat = 168.0
    }
}

protocol QRCreationViewDelegate: AnyObject {
    func qrCreationViewDidShare(_ qrCreationView: QRCreationView)
    func qrCreationView(_ qrCreationView: QRCreationView, didSelect text: String)
}
