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
//  TransactionFilterOptionView.swift

import UIKit

class TransactionFilterOptionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var dateImageView = DateWithTextImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var dateLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
    }()
    
    private lazy var selectedIconImageView = UIImageView(image: img("icon-check"))
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        selectedIconImageView.isHidden = true
    }
    
    override func prepareLayout() {
        setupDateImageViewLayout()
        setupDateLabelLayout()
        setupTitleLabelLayout()
        setupSelectedIconImageViewLayout()
    }
}

extension TransactionFilterOptionView {
    private func setupDateImageViewLayout() {
        addSubview(dateImageView)
        
        dateImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateImageView.snp.trailing).offset(layout.current.labelHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateImageView.snp.trailing).offset(layout.current.labelHorizontalInset)
            make.bottom.equalTo(dateLabel.snp.top)
            make.centerY.equalTo(dateImageView).priority(.medium)
        }
    }
    
    private func setupSelectedIconImageViewLayout() {
        addSubview(selectedIconImageView)
        
        selectedIconImageView.snp.makeConstraints { make in
            make.size.equalTo(layout.current.imageSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}

extension TransactionFilterOptionView {
    func setDateImage(_ image: UIImage?) {
        dateImageView.setImage(image)
    }
    
    func setDayText(_ day: String) {
        dateImageView.setDate(day)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDate(_ date: String) {
        dateLabel.text = date
    }
    
    func removeDateLabel() {
        dateLabel.removeFromSuperview()
    }
    
    func setSelected() {
        selectedIconImageView.isHidden = false
        titleLabel.textColor = Colors.General.selected
        dateImageView.setSelected()
    }
    
    func setDeselected() {
        selectedIconImageView.isHidden = true
        titleLabel.textColor = Colors.Text.primary
        dateImageView.setDeselected()
    }
    
    func setDayLabelHidden(_ isHidden: Bool) {
        dateImageView.setDayLabelHidden(isHidden)
    }
}

extension TransactionFilterOptionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 8.0
        let labelHorizontalInset: CGFloat = 12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
