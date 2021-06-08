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
//  BottomInformationView.swift

import UIKit

class BottomInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
    }()
    
    private(set) lazy var imageView = UIImageView()
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupExplanationLabelLayout()
    }
}

extension BottomInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.imageVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.explanationLabelInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension BottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 32.0
        let imageVerticalInset: CGFloat = 28.0
        let explanationLabelInset: CGFloat = 20.0
    }
}
