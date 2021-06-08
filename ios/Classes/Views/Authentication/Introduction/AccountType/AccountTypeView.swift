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
//  AccountTypeView.swift

import UIKit

class AccountTypeView: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var typeImageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.left)
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withAlignment(.left)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-introduction-arrow-right"))
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
        setupTypeImageViewLayout()
        setupArrowImageViewLayout()
    }
}

extension AccountTypeView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLeadingInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.trailing.equalToSuperview().inset(layout.current.titleTrailingInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(layout.current.titleTrailingInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.minimumInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupTypeImageViewLayout() {
        addSubview(typeImageView)
        
        typeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.iconSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(typeImageView)
            make.size.equalTo(layout.current.arrowIconSize)
        }
    }
}

extension AccountTypeView {
    func bind(_ viewModel: AccountTypeViewModel) {
        typeImageView.image = viewModel.typeImage
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
    }
}

extension AccountTypeView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let iconSize = CGSize(width: 48.0, height: 48.0)
        let titleLeadingInset: CGFloat = 88.0
        let titleTrailingInset: CGFloat = 60.0
        let arrowIconSize = CGSize(width: 24.0, height: 24.0)
        let separatorHeight: CGFloat = 1.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 24.0
        let minimumInset: CGFloat = 4.0
    }
}
