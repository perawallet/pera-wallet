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
//  ConfirmationBottomInformationView.swift

import UIKit

class ConfirmationBottomInformationView: BottomInformationView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTitleColor(Colors.ButtonText.primary)
    }()
    
    weak var delegate: ConfirmationBottomInformationViewDelegate?
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToDoneButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupActionButtonLayout()
    }
}

extension ConfirmationBottomInformationView {
    @objc
    private func notifyDelegateToDoneButtonTapped() {
        delegate?.confirmationBottomInformationViewDidTapActionButton(self)
    }
}

extension ConfirmationBottomInformationView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension ConfirmationBottomInformationView {
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
    }
}

extension ConfirmationBottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 28.0
        let buttonHorizontalInset: CGFloat = 32.0
    }
}

protocol ConfirmationBottomInformationViewDelegate: class {
    func confirmationBottomInformationViewDidTapActionButton(_ confirmationBottomInformationView: ConfirmationBottomInformationView)
}
