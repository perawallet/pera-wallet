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
//  AccountSelectionView.swift

import UIKit

class SelectionView: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var leftExplanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withText("asset-title".localized)
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.backgroundColor = Colors.Background.secondary
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.hint)
            .withText("send-choose-asset".localized)
            .withLine(.single)
    }()
    
    private(set) lazy var rightInputAccessoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentMode = .center
        return button
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        if !isDarkModeDisplay {
            containerView.applySmallShadow()
        }
    }
    
    override func prepareLayout() {
        setupLeftExplanationLabelLayout()
        setupContainerViewLayout()
        setupRightInputAccessoryButtonLayout()
        setupDetailLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            containerView.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            containerView.removeShadows()
        } else {
            containerView.applySmallShadow()
        }
    }
}

extension SelectionView {
    private func setupLeftExplanationLabelLayout() {
        addSubview(leftExplanationLabel)
        
        leftExplanationLabel.setContentHuggingPriority(.required, for: .horizontal)
        leftExplanationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        leftExplanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.top.equalTo(leftExplanationLabel.snp.bottom).offset(layout.current.containerViewTopInset)
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        containerView.addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupDetailLabelLayout() {
        containerView.addSubview(detailLabel)
        
        detailLabel.setContentHuggingPriority(.required, for: .horizontal)
        detailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.bottom.equalToSuperview().inset(layout.current.detailVerticalInset)
        }
    }
}

extension SelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
        let containerViewTopInset: CGFloat = 8.0
        let detailVerticalInset: CGFloat = 16.0
        let buttonWidth: CGFloat = 25.0
    }
}
