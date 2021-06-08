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
//  QRBottomInformationView.swift

import UIKit

class QRBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-main-button"))
            .withTitle("title-approve".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.ButtonText.primary)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-cancel".localized)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.ButtonText.secondary)
    }()
    
    weak var delegate: QRBottomInformationViewDelegate?
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupActionButtonLayout()
        setupCancelButtonLayout()
    }
}

extension QRBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(actionButton.snp.bottom).offset(layout.current.buttonOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension QRBottomInformationView {
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.qrBottomInformationViewDidTapCancelButton(self)
    }
    
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.qrBottomInformationViewDidTapActionButton(self)
    }
}

extension QRBottomInformationView {
    func bind(_ viewModel: BottomInformationViewModel) {
        titleLabel.attributedText = viewModel.attributedTitle
        titleLabel.textAlignment = viewModel.titleAlignment
        explanationLabel.attributedText = viewModel.attributedExplanation
        explanationLabel.textAlignment = viewModel.explanationAlignment
        imageView.image = viewModel.image
    }
}

extension QRBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonOffset: CGFloat = 12.0
        let verticalInset: CGFloat = 28.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol QRBottomInformationViewDelegate: class {
    func qrBottomInformationViewDidTapCancelButton(_ qrBottomInformationView: QRBottomInformationView)
    func qrBottomInformationViewDidTapActionButton(_ qrBottomInformationView: QRBottomInformationView)
}
