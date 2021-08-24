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
//  ActionBottomInformationView.swift

import UIKit

class ActionBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(Colors.ButtonText.primary)
            .withAlignment(.center)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(Colors.Text.primary)
            .withAlignment(.center)
    }()
    
    weak var delegate: ActionBottomInformationViewDelegate?
    
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

extension ActionBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(actionButton.snp.bottom).offset(layout.current.cancelButtonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension ActionBottomInformationView {
    @objc
    private func notifyDelegateToActionButtonTapped() {
        delegate?.actionBottomInformationViewDidTapActionButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelButtonTapped() {
        delegate?.actionBottomInformationViewDidTapCancelButton(self)
    }
}

extension ActionBottomInformationView {
    func bind(_ viewModel: BottomInformationViewModel) {
        titleLabel.attributedText = viewModel.attributedTitle
        titleLabel.textAlignment = viewModel.titleAlignment
        explanationLabel.attributedText = viewModel.attributedExplanation
        explanationLabel.textAlignment = viewModel.explanationAlignment
        imageView.image = viewModel.image

        if let actionTitle = viewModel.actionButtonTitle {
            actionButton.setTitle(actionTitle, for: .normal)
        }

        if let actionImage = viewModel.actionImage {
            actionButton.setBackgroundImage(actionImage, for: .normal)
        }

        cancelButton.setTitle(viewModel.closeButtonTitle, for: .normal)

        if let closeBackgroundImage = viewModel.closeImage {
            cancelButton.setBackgroundImage(closeBackgroundImage, for: .normal)
        }
    }
}

extension ActionBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let cancelButtonTopInset: CGFloat = 12.0
        let buttonHorizontalInset: CGFloat = 32.0
    }
}

protocol ActionBottomInformationViewDelegate: AnyObject {
    func actionBottomInformationViewDidTapActionButton(_ actionBottomInformationView: ActionBottomInformationView)
    func actionBottomInformationViewDidTapCancelButton(_ actionBottomInformationView: ActionBottomInformationView)
}
