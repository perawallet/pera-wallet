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
//  OptionsContextView.swift

import UIKit

class OptionsContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var iconImageView = UIImageView()
    
    private(set) lazy var optionLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupIconImageViewLayout()
        setupOptionLabelLayout()
    }
}

extension OptionsContextView {
    private func setupIconImageViewLayout() {
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupOptionLabelLayout() {
        addSubview(optionLabel)
        
        optionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.labelLefInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension OptionsContextView {
    func bind(_ viewModel: OptionsViewModel) {
        iconImageView.image = viewModel.image
        optionLabel.text = viewModel.title
        optionLabel.textColor = viewModel.titleColor
    }

    func bind(_ viewModel: AccountRecoverOptionsViewModel) {
        iconImageView.image = viewModel.image
        optionLabel.text = viewModel.title
    }
}

extension OptionsContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let labelLefInset: CGFloat = 56.0
    }
}
