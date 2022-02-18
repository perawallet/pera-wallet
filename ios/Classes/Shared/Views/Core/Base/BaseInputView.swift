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
//  BaseInputView.swift

import UIKit

class BaseInputView: BaseView {
    private let layout = Layout<LayoutConstants>()
    
    var nextButtonMode = NextButtonMode.next
    private let displaysExplanationText: Bool
    let displaysLeftImageView: Bool
    let displaysRightInputAccessoryButton: Bool
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel().withFont(UIFont.font(withWeight: .regular(size: 14.0))).withTextColor(Colors.Text.primary).withAlignment(.left)
    }()
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.backgroundColor = Colors.Background.secondary
        return view
    }()
    
    private(set) lazy var leftImageView = UIImageView()
    
    private(set) lazy var rightInputAccessoryButton = UIButton(type: .custom)
    
    weak var delegate: InputViewDelegate?
    
    init(displaysExplanationText: Bool = true, displaysRightInputAccessoryButton: Bool = false, displaysLeftImageView: Bool = false) {
        self.displaysExplanationText = displaysExplanationText
        self.displaysRightInputAccessoryButton = displaysRightInputAccessoryButton
        self.displaysLeftImageView = displaysLeftImageView
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if !isDarkModeDisplay {
            contentView.applySmallShadow()
        }
    }
    
    override func linkInteractors() {
        rightInputAccessoryButton.addTarget(self, action: #selector(notifyDelegateToAccessoryButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContentViewLayout()
        setupLeftImageViewLayout()
        setupRightInputAccessoryButtonLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            contentView.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            contentView.removeShadows()
        } else {
            contentView.applySmallShadow()
        }
    }
}

extension BaseInputView {
    private func setupExplanationLabelLayout() {
        if !displaysExplanationText {
            return
        }
        
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupContentViewLayout() {
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            
            if displaysExplanationText {
                make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            } else {
                make.top.equalToSuperview().offset(layout.current.contentViewMaximumTopInset)
            }
        }
    }
    
    private func setupLeftImageViewLayout() {
        if !displaysLeftImageView {
            return
        }
        
        contentView.addSubview(leftImageView)
        
        leftImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.iconLeadingInset)
            make.top.equalToSuperview().inset(layout.current.iconTopInset)
            make.size.equalTo(layout.current.iconSize)
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        if !displaysRightInputAccessoryButton {
            return
        }
        
        contentView.addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonInset)
            make.top.equalToSuperview().inset(layout.current.buttonInset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
}

extension BaseInputView {
    @objc
    func notifyDelegateToAccessoryButtonTapped() {
        delegate?.inputViewDidTapAccessoryButton(inputView: self)
    }
}

extension BaseInputView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let contentViewTopInset: CGFloat = 8.0
        let contentViewMaximumTopInset: CGFloat = 10.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let iconSize = CGSize(width: 24.0, height: 24.0)
        let iconTopInset: CGFloat = 12.0
        let iconLeadingInset: CGFloat = 16.0
        let buttonInset: CGFloat = 12.0
    }
}

extension BaseInputView {
    enum NextButtonMode {
        case next
        case submit
    }
}
