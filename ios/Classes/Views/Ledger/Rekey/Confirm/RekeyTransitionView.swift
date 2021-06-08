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
//  RekeyTransitionView.swift

import UIKit

class RekeyTransitionView: BaseView {
    
    override var intrinsicContentSize: CGSize {
        return layout.current.contentSize
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var oldTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var oldValueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-right"))
    
    private lazy var newTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var newValueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        if !isDarkModeDisplay {
            applySmallShadow()
        }
    }
    
    override func prepareLayout() {
        setupArrowImageViewLayout()
        setupOldTitleLabelLayout()
        setupOldValueLabelLayout()
        setupNewTitleLabelLayout()
        setupNewValueLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
        }
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            removeShadows()
        } else {
            applySmallShadow()
        }
    }
}

extension RekeyTransitionView {
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(layout.current.iconSize)
        }
    }
    
    private func setupOldTitleLabelLayout() {
        addSubview(oldTitleLabel)
        
        oldTitleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-layout.current.arrowOffset)
            make.bottom.equalTo(arrowImageView.snp.top).inset(layout.current.titleBottomInset)
            make.leading.greaterThanOrEqualToSuperview()
        }
    }
    
    private func setupOldValueLabelLayout() {
        addSubview(oldValueLabel)
        
        oldValueLabel.snp.makeConstraints { make in
            make.top.equalTo(oldTitleLabel.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalTo(oldTitleLabel)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading)
        }
    }
    
    private func setupNewTitleLabelLayout() {
        addSubview(newTitleLabel)
        
        newTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(oldTitleLabel)
            make.leading.equalTo(arrowImageView.snp.trailing).offset(layout.current.arrowOffset)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    private func setupNewValueLabelLayout() {
        addSubview(newValueLabel)
        
        newValueLabel.snp.makeConstraints { make in
            make.top.equalTo(newTitleLabel.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalTo(newTitleLabel)
            make.trailing.lessThanOrEqualToSuperview()
            make.leading.lessThanOrEqualTo(arrowImageView.snp.trailing)
        }
    }
}

extension RekeyTransitionView {
    func setOldTitleLabel(_ title: String?) {
        oldTitleLabel.text = title
    }
    
    func setOldValueLabel(_ value: String?) {
        oldValueLabel.text = value
    }
    
    func setNewTitleLabel(_ title: String?) {
        newTitleLabel.text = title
    }
    
    func setNewValueLabel(_ value: String?) {
        newValueLabel.text = value
    }
}

extension RekeyTransitionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let contentSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 100.0)
        let arrowOffset: CGFloat = 40.0
        let titleBottomInset: CGFloat = 4.0
        let topInset: CGFloat = 8.0
        let iconSize = CGSize(width: 24.0, height: 24.0)
    }
}
